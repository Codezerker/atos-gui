//
//  ATSSystemShellSymbolConverter.m
//  atos-gui
//
//  Created by Yan Li on 21/08/19.
//  Copyright © 2019 Codezerker. All rights reserved.
//

#import "ATSSystemShellSymbolConverter.h"

#import "NSTask+EasyExecute.h"

static NSString * const SYSTEM_SHELL_PATH = @"/bin/sh";
static NSString * const SYSTEM_ATOS_PATH = @"/usr/bin/atos";

static NSString * const ADDRESS_FORMAT = @"0x%llX";

static NSString * const INPUT_SEPARATOR = @" ";
static NSString * const OUTPUT_SEPARATOR = @"\n";

@implementation ATSSystemShellSymbolConverter

- (NSArray<NSString *> *)symbolicator:(ATSSymbolicator *)symbolicator
                  symbolsForAddresses:(NSArray<NSString *> *)addresses
                          loadAddress:(NSString *)loadAddress
                       executablePath:(NSString *)executablePath
{
    NSString *command = [NSString stringWithFormat:@"\"%@\" -o \"%@\" -l %@ %@",
                         SYSTEM_ATOS_PATH,
                         executablePath,
                         loadAddress,
                         [addresses componentsJoinedByString:INPUT_SEPARATOR]];
    
    NSLog(@"$ %@", command);
    
    NSString *result = [NSTask ats_executeAndReturnStdOut:SYSTEM_SHELL_PATH
                                                arguments:@[@"-c", command]];
    
    NSLog(@"%@", result);
    
    return [result componentsSeparatedByString:OUTPUT_SEPARATOR];
}

@end
