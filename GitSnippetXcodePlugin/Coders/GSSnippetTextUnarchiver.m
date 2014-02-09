//
//  GSSnippetTextUnarchiver.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSSnippetTextUnarchiver.h"
#import "GSSnippet.h"

@interface GSSnippetTextUnarchiver ()
@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSDictionary *dictionary;
@end


@implementation GSSnippetTextUnarchiver

+ (id)unarchiveObjectWithString:(NSString*)string {
    return [[self alloc] initForReadingWithString:string];
}

+ (id)unarchiveObjectWithFile:(NSString*)file {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
return [self unarchiveObjectWithString:[NSString stringWithContentsOfFile:file]];
#pragma GCC diagnostic pop
}

- (id)initForReadingWithString:(NSString*)string {
    self = [super init];
    if (self) {
        self.string = string;
    }
    return self;
}

- (id)initForReadingWithFile:(NSString*)file {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    return [self initForReadingWithString:[NSString stringWithContentsOfFile:file]];
#pragma GCC diagnostic pop
}


- (NSDictionary*)dictionary {
    if (!_dictionary) {
        _dictionary = [self dictionaryFromString:self.string];
    }
    return _dictionary;
}

- (NSDictionary*)dictionaryFromString:(NSString*)string {
    NSMutableDictionary *d = [@{} mutableCopy];
    
    __block BOOL isParsingHeader = YES;
    __block NSString *contents = @"";
    
    NSError *error = NULL;
    NSString *pattern = @"//\\s*(\\w*)\\s*:\\s*(.*)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    __block int i = 0;
    [self.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        
        if (![line hasPrefix:@"//"]) {
            isParsingHeader = NO;
        }
        
        if (isParsingHeader) {
            __block NSString *key = nil;
            __block NSString *value = nil;
            [regex enumerateMatchesInString:line
                                    options:0
                                      range:NSMakeRange(0, line.length)
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                     
                                     key = [[line substringWithRange:[result rangeAtIndex:1]] lowercaseString];
                                     value = [line substringWithRange:[result rangeAtIndex:2]];
                                     d[key] = value;
                                 }];
            
            if (!key && !value) {
                if (i < 2) {
                    value = [[line substringWithRange:NSMakeRange(2, line.length-2)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if (i == 0) {
                        d[@"title"] = value;
                    }
                    if (i == 1) {
                        d[@"summary"] = value;
                    }
                }
            }
            
        } else {
            contents = [[contents stringByAppendingString:line] stringByAppendingString:@"\n"];
        }
        
        i++;
    }];
    
    d[@"contents"] = contents;
    
    return [d copy];
}

- (NSString*)shortKeyForKey:(NSString*)key {
    if ([key rangeOfString:XSGSnippetKeyPrefix].location != NSNotFound) {
        return [[key substringFromIndex:XSGSnippetKeyPrefix.length] lowercaseString];
    }
    return [key lowercaseString];
}

- (NSArray*)decodeArrayOfStringsForKey:(id)key {
    NSString *string = self.dictionary[[self shortKeyForKey:key]];
    
    if ([string isKindOfClass:NSString.class]) {
        NSRange start = [string rangeOfString:@"["];
        NSRange end = [string rangeOfString:@"]"];
        if (
            start.location != NSNotFound &&
            end.location != NSNotFound
            ) {
            
            NSString *contents = [[string substringToIndex:end.location] substringFromIndex:start.location+1];
            return [contents componentsSeparatedByString:@","];
        }
    }
    return nil;
}

- (id)decodeObjectForKey:(NSString *)key {
    
    id value = self.dictionary[[self shortKeyForKey:key]];
    
    if (
        [key isEqualToString:XSGSnippetTitleKey] ||
        [key isEqualToString:XSGSnippetSummaryKey] ||
        [key isEqualToString:XSGSnippetContentsKey]
        ) {
        return value;
    }
    
    NSArray *array = [self decodeArrayOfStringsForKey:key];
    if (array) {
        value = array;
    }
    
    return value;
}

- (BOOL)decodeBoolForKey:(NSString*)key {
    if ([@"yes" compare:self.dictionary[[self shortKeyForKey:key]] options:NSCaseInsensitiveSearch]) {
        return YES;
    }
    return [self.dictionary[[self shortKeyForKey:key]] boolValue];
}

- (NSInteger)decodeIntegerForKey:(NSString*)key {
    return [self.dictionary[[self shortKeyForKey:key]] integerValue];
}

@end
