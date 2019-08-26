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
    
    static std::regex BINARY_IMAGE_NAME_AND_SYMBOL_ADDRESS_REGEX{ R"~((?:^|$|\r\n|\n)\s*[0-9]+\s+(\S+)\s+(0[xX][0-9a-fA-F]+))~" };
    static std::regex BINARY_IMAGE_NAME_AND_LOAD_ADDRESS_REGEX{ R"~((?:^|$|\r\n|\n)\s*(0[xX][0-9a-fA-F]+)\s+-\s+(0[xX][0-9a-fA-F]+)\s+(\S+))~" };
    static std::regex HEX_STRING_REGEX{ "0[xX][0-9a-fA-F]+" };
        
    struct BinaryImage
    {
        std::string loadAddress;
        std::string name;
    };
    
    std::vector<BinaryImage>
    extract_binary_images_from_string( const std::string& string )
    {
        std::vector<BinaryImage> binaryImages;

        const auto begin = std::sregex_iterator{ string.begin(), string.end(), BINARY_IMAGE_NAME_AND_LOAD_ADDRESS_REGEX };
        const auto end = std::sregex_iterator{};
        for (std::sregex_iterator iter = begin; iter != end; ++iter)
        {
            std::smatch match = *iter;
            if (match.size() < 4)
            {
                continue;
            }
            
            NSLog(@"Found load address %s for binary image '%s'", match[1].str().c_str(), match[3].str().c_str());
            
            BinaryImage image{ match[1].str(), match[3].str() };
            binaryImages.emplace_back(std::move(image));
            
            // Note: Abort the match, assuming the first match is always the binary image we are looking for
            break;
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
        
        const auto begin = std::sregex_iterator{ string.begin(), string.end(), BINARY_IMAGE_NAME_AND_SYMBOL_ADDRESS_REGEX };
        const auto end = std::sregex_iterator{};
        for (std::sregex_iterator iter = begin; iter != end; ++iter)
        {
            std::smatch match = *iter;
            if (match.size() < 3)
            {
                continue;
            }
            
            NSLog(@"Found symbol address %s for binary image '%s'", match[2].str().c_str(), match[1].str().c_str());
            
            SymbolAddress address{ match[2].str(), match[1].str() };
            addresses.emplace(std::move(address));
        }

        return addresses;
    }

    std::set<SymbolAddress>
    extract_hex_addresses_from_string( const std::string& string )
    {
        std::set<SymbolAddress> addresses;
        
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
    }
    return self;
}

- (instancetype)initWithSymbolConverter:(id<ATSSymbolConverter>)symbolConverter
{
    if (self = [super init])
    {
        _symbolConverter = symbolConverter;
        _symbolicatingQueue = create_symbolicating_queue();
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

        NSString *loadAddress;
        {
            const std::vector<BinaryImage> binaryImages = extract_binary_images_from_string(string);
            if (overrideLoadAddress)
            {
                loadAddress = overrideLoadAddress;
            }
            else if (!binaryImages.empty())
            {
                loadAddress = [NSString stringWithUTF8String:binaryImages[0].loadAddress.c_str()];
            }
            else
            {
                loadAddress = @"LoadAddressNotFound";
            }
        }
        
        NSMutableArray *addresses;
        {
            std::set<SymbolAddress> addressesToSymbolicate = extract_crash_report_symbol_addresses_from_string(string);
            if (addressesToSymbolicate.empty())
            {
                NSLog(@"Failed to extract symbol addresses with expected Darwin crash report pattern, extracting all hexadecimal strings...");
                addressesToSymbolicate = extract_hex_addresses_from_string(string);
            }

            addresses = [NSMutableArray arrayWithCapacity:addressesToSymbolicate.size()];
            for (const SymbolAddress& symbolAddress : addressesToSymbolicate)
            {
                [addresses addObject:[NSString stringWithUTF8String:symbolAddress.address.c_str()]];
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
