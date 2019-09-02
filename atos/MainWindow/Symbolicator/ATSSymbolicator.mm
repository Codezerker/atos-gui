//
//  ATSSymbolicator.m
//  atos-gui
//
//  Created by Yan Li on 20/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import "ATSSymbolicator.h"

#import <cstdint>
#import <regex>
#import <set>
#import <string>
#import <unordered_map>
#import <vector>

#import "ATSSystemShellSymbolConverter.h"

#pragma mark - Private C++ helper classes/functions

namespace
{
    
    inline
    dispatch_queue_t create_symbolicating_queue()
    {
        return dispatch_queue_create("com.codezerker.atos-gui.atos", DISPATCH_QUEUE_CONCURRENT);
    }
    
    static std::regex BINARY_IMAGE_NAME_AND_SYMBOL_ADDRESS_REGEX{ R"~((?:^|$|\r\n|\n)\s*[0-9]+\s+((?:\w+\s?)*\s*)\s+(0[xX][0-9a-fA-F]+))~" };
    static std::regex BINARY_IMAGE_NAME_AND_LOAD_ADDRESS_REGEX{ R"~((?:^|$|\r\n|\n)\s*(0[xX][0-9a-fA-F]+)\s+-\s+(0[xX][0-9a-fA-F]+)\s+((?:\w+\s?)*\s*))~" };
    static std::regex HEX_STRING_REGEX{ "0[xX][0-9a-fA-F]+" };
    
    std::string string_by_trimming_whitespaces( const std::string& str )
    {
        NSString *nsstring = [NSString stringWithUTF8String:str.c_str()];
        nsstring = [nsstring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return std::string{ nsstring.UTF8String };
    }

    struct BinaryImage
    {
        std::string loadAddress;
        std::string name;
    };
    
    std::vector<BinaryImage>
    extract_binary_images_from_string( const std::string& string )
    {
        std::vector<BinaryImage> binaryImages;

        try
        {
            const auto begin = std::sregex_iterator{ string.begin(), string.end(), BINARY_IMAGE_NAME_AND_LOAD_ADDRESS_REGEX };
            const auto end = std::sregex_iterator{};
            for (std::sregex_iterator iter = begin; iter != end; ++iter)
            {
                std::smatch match = *iter;
                if (match.size() < 4)
                {
                    continue;
                }
                
                const std::string loadAddress = string_by_trimming_whitespaces(match[1].str());
                const std::string binaryImageName = string_by_trimming_whitespaces(match[3].str());
                
                NSLog(@"Found load address %s for binary image '%s'", loadAddress.c_str(), binaryImageName.c_str());
                
                BinaryImage image{ std::move(loadAddress), std::move(binaryImageName) };
                binaryImages.emplace_back(std::move(image));
                
                // Note: Abort the match, assuming the first match is always the binary image we are looking for
                break;
            }
        }
        catch (...)
        {
            NSLog(@"[ERROR] Failed to extract binary image name and load address!");
        }
        
        return binaryImages;
    }
    
    struct SymbolAddress
    {
        std::string address;
        std::string binaryImageName;
    };
    
    bool
    operator<(const SymbolAddress& lhs, const SymbolAddress& rhs)
    {
        return lhs.address < rhs.address;
    }
    
    std::set<SymbolAddress>
    extract_crash_report_symbol_addresses_from_string( const std::string& string )
    {
        std::set<SymbolAddress> addresses;
        
        try
        {
            const auto begin = std::sregex_iterator{ string.begin(), string.end(), BINARY_IMAGE_NAME_AND_SYMBOL_ADDRESS_REGEX };
            const auto end = std::sregex_iterator{};
            for (std::sregex_iterator iter = begin; iter != end; ++iter)
            {
                std::smatch match = *iter;
                if (match.size() < 3)
                {
                    continue;
                }
                
                const std::string addressString = string_by_trimming_whitespaces(match[2].str());
                const std::string binaryImageName = string_by_trimming_whitespaces(match[1].str());
                
                NSLog(@"Found symbol address %s for binary image '%s'", addressString.c_str(), binaryImageName.c_str());
                
                SymbolAddress address{ std::move(addressString), std::move(binaryImageName) };
                addresses.emplace(std::move(address));
            }
        }
        catch (...)
        {
            NSLog(@"[ERROR] Failed to extract symbol addresses with crash report pattern!");
        }

        return addresses;
    }

    std::set<SymbolAddress>
    extract_hex_addresses_from_string( const std::string& string )
    {
        std::set<SymbolAddress> addresses;
        
        try
        {
            const auto begin = std::sregex_iterator{ string.begin(), string.end(), HEX_STRING_REGEX };
            const auto end = std::sregex_iterator{};
            for (std::sregex_iterator iter = begin; iter != end; ++iter)
            {
                std::smatch match = *iter;
                if (match.size() < 1)
                {
                    continue;
                }
                
                NSLog(@"Found hexadecimal address %s", match[0].str().c_str());
                
                SymbolAddress address{ match[0].str(), std::string{} };
                addresses.emplace(std::move(address));
            }
        }
        catch (...)
        {
            NSLog(@"[ERROR] Failed to extract hexadecimal addresses!");
        }

        return addresses;
    }
    
} // namespace

#pragma mark - ATSSymbolicator

@interface ATSSymbolicator ()

@property (nonatomic, strong) dispatch_queue_t symbolicatingQueue;

@end

@implementation ATSSymbolicator

- (instancetype)init
{
    if (self = [super init])
    {
        _symbolConverter = [[ATSSystemShellSymbolConverter alloc] init];
        _symbolicatingQueue = create_symbolicating_queue();
        _alwaysMatchAllHexadecimalStringsAsSymbolAddress = NO;
    }
    return self;
}

- (instancetype)initWithSymbolConverter:(id<ATSSymbolConverter>)symbolConverter
{
    if (self = [super init])
    {
        _symbolConverter = symbolConverter;
        _symbolicatingQueue = create_symbolicating_queue();
        _alwaysMatchAllHexadecimalStringsAsSymbolAddress = NO;
    }
    return self;
}

- (void)symbolicateString:(NSString *)stringToSymbolicate
            executableURL:(NSURL *)executableURL
      overrideLoadAddress:(NSString * _Nullable)overrideLoadAddress
      withCompletionBlock:(void (^)(NSDictionary *))completion
{
    dispatch_async(self.symbolicatingQueue, ^{
        const std::string string{ [stringToSymbolicate UTF8String] };

        NSMutableArray *addresses;
        {
            std::set<SymbolAddress> addressesToSymbolicate;
            if (self.alwaysMatchAllHexadecimalStringsAsSymbolAddress)
            {
                NSLog(@"Extracting all hexadecimal strings as symbol addresses.");
                addressesToSymbolicate = extract_hex_addresses_from_string(string);
                if (addressesToSymbolicate.empty())
                {
                    NSLog(@"Can't find any hexadecimal string.");
                }
            }
            else
            {
                addressesToSymbolicate = extract_crash_report_symbol_addresses_from_string(string);
                if (addressesToSymbolicate.empty())
                {
                    NSLog(@"Failed to extract symbol addresses with expected Darwin crash report pattern, falling back to extract all hexadecimal strings.");
                    addressesToSymbolicate = extract_hex_addresses_from_string(string);
                    if (addressesToSymbolicate.empty())
                    {
                        NSLog(@"Can't find any hexadecimal string.");
                    }
                }
            }
            
            addresses = [NSMutableArray arrayWithCapacity:addressesToSymbolicate.size()];
            for (const SymbolAddress& symbolAddress : addressesToSymbolicate)
            {
                [addresses addObject:[NSString stringWithUTF8String:symbolAddress.address.c_str()]];
            }
        }
        
        if (addresses.count == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@{});
            });
            return;
        }
        
        NSString *loadAddress;
        {
            const std::vector<BinaryImage> binaryImages = extract_binary_images_from_string(string);
            if (overrideLoadAddress)
            {
                loadAddress = overrideLoadAddress;
            }
            else if (!binaryImages.empty())
            {
                // Assuming the first binary image is always what we want
                loadAddress = [NSString stringWithUTF8String:binaryImages[0].loadAddress.c_str()];
            }
            else
            {
                loadAddress = @"LoadAddressNotFound";
            }
        }
        
        NSString * executablePath = [executableURL path];
        
        NSArray *symbols = [self.symbolConverter symbolicator:self
                                          symbolsForAddresses:addresses
                                                  loadAddress:loadAddress
                                               executablePath:executablePath];
        
        NSMutableDictionary *symbolLookupTable = [NSMutableDictionary dictionary];
        {
            [symbols enumerateObjectsUsingBlock:^(NSString *symbol, NSUInteger idx, BOOL *stop) {
                NSString *address = addresses[idx];
                if (symbol.length > 0 && ![symbol hasPrefix:address])
                {
                    symbolLookupTable[address] = symbol;
                }
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(symbolLookupTable);
        });
    });
}

@end
