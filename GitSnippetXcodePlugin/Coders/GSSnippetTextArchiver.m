//
//  GSSnippetTextArchiver.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSSnippetTextArchiver.h"
#import "GSSnippet.h"

@interface GSSnippetTextArchiver ()
@property (nonatomic, strong) NSMutableString *string;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, copy) NSString *contents;
@end

@implementation GSSnippetTextArchiver

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path {
    GSSnippetTextArchiver *archiver = [[GSSnippetTextArchiver alloc] init];
    [rootObject encodeWithCoder:archiver];
    
    [archiver.string appendString:(archiver.title?:@"")];
    [archiver.string appendString:(archiver.summary?:@"")];
    [archiver.string appendString:@"//\n"];
    for (NSString *string in archiver.array) {
        [archiver.string appendString:string];
    }
    [archiver.string appendString:@"\n"];
    [archiver.string appendString:(archiver.contents?:@"")];

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    return [archiver.string writeToFile:path atomically:NO];
#pragma GCC diagnostic pop
}

- (id)init {
    return [self initForWritingWithMutableString:[@"" mutableCopy]];
}

- (id)initForWritingWithMutableString:(NSMutableString*)string {
    self = [super init];
    if (self) {
        self.string = string;
        self.array = [@[] mutableCopy];
    }
    return self;
}

- (NSString*)shortKeyForKey:(NSString*)key {
    if ([key rangeOfString:XSGSnippetKeyPrefix].location != NSNotFound) {
    return [key substringFromIndex:XSGSnippetKeyPrefix.length];
    }
    return key;
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key {
    [self.array addObject:[NSString stringWithFormat:@"// %@: %@\n", [self shortKeyForKey:key], (boolv ? @"yes":@"no")]];
}

- (void)encodeObject:(id)object forKey:(NSString *)key {
    
    if (!object) return;
    
    if ([object isKindOfClass:NSArray.class]) {
        object = [NSString stringWithFormat:@"[%@]", [object componentsJoinedByString:@", "]];
    }
    
    if ([key isEqualToString:XSGSnippetTitleKey]) {
        [self encodeTitle:object];
        
    } else if ([key isEqualToString:XSGSnippetSummaryKey]) {
        [self encodeSummary:object];
        
    } else if ([key isEqualToString:XSGSnippetContentsKey]) {
        [self encodeContents:object];
    } else {
        [self.array addObject:[NSString stringWithFormat:@"// %@: %@\n", [self shortKeyForKey:key], object]];
    }
}

- (void)encodeInteger:(NSInteger)integer forKey:(NSString *)key {
    [self.array addObject:[NSString stringWithFormat:@"// %@: %li\n", [self shortKeyForKey:key], (long)integer]];
}

- (void)encodeTitle:(NSString*)title {
    self.title = [NSString stringWithFormat:@"// Title: %@\n", title];
}

- (void)encodeSummary:(NSString*)summary {
    self.summary = [NSString stringWithFormat:@"// Summary: %@\n", summary];
}

- (void)encodeContents:(NSString*)contents {
    self.contents = contents;
}

@end
