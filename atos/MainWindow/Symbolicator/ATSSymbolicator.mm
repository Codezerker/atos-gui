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
            
            break; // FIXME: Looks like only the main binary load address is useful?
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
    extract_symbol_addresses_from_string( const std::string& string )
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
            addresses.insert(std::move(address));
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
    NSString * executablePath = [executableURL path];
    
    dispatch_async(self.symbolicatingQueue, ^{
        const std::string string{ [stringToSymbolicate UTF8String] };
        
        const std::vector<BinaryImage> binaryImages = extract_binary_images_from_string(string);
        const std::set<SymbolAddress> addressesToSymbolicate = extract_symbol_addresses_from_string(string);

        NSMutableDictionary *symbolLookupTable = [NSMutableDictionary dictionary];
        
        for (const SymbolAddress& symbolAddress : addressesToSymbolicate)
        {
            NSString *loadAddress;
            if (overrideLoadAddress)
            {
                loadAddress = overrideLoadAddress;
            }
            else
            {
                // TODO: Build a <name, loadAddress> lookup table, so that O(NM) -> O(N)
                const auto find_it = std::find_if(
                    binaryImages.cbegin(),
                    binaryImages.cend(),
                    [&symbolAddress](const BinaryImage& image)
                    {
                        return symbolAddress.binaryImageName == image.name           // com.company.App
                               || "+" + symbolAddress.binaryImageName == image.name; // +com.company.App
                    }
                );
                if (find_it == binaryImages.cend())
                {
                    continue;
                }
            
                loadAddress = [NSString stringWithUTF8String:find_it->loadAddress.c_str()];
            }

            NSString *address = [NSString stringWithUTF8String:symbolAddress.address.c_str()];
            NSString *symbol = [self.symbolConverter symbolicator:self
                                                 symbolForAddress:address
                                                      loadAddress:loadAddress
                                                   executablePath:executablePath];
            
            if (symbol.length > 0 && ![symbol hasPrefix:address])
            {
                NSString *symbolAddressString = [NSString stringWithUTF8String:symbolAddress.address.c_str()];
                symbolLookupTable[symbolAddressString] = symbol;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(symbolLookupTable);
        });
    });
}

@end
