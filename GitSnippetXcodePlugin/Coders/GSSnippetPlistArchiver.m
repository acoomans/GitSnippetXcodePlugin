//
//  GSSnippetPlistArchiver.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSSnippetPlistArchiver.h"

@interface GSSnippetPlistArchiver ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation GSSnippetPlistArchiver

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path {
    GSSnippetPlistArchiver *archiver = [[GSSnippetPlistArchiver alloc] init];
    [rootObject encodeWithCoder:archiver];
    return [archiver.dictionary writeToFile:path atomically:NO];
}

- (id)init {
    return [self initForWritingWithMutableDictionary:[@{} mutableCopy]];
}

- (id)initForWritingWithMutableDictionary:(NSMutableDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
    }
    return self;
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key {
    self.dictionary[key] = @(boolv);
}

- (void)encodeObject:(id)object forKey:(NSString *)key {
    self.dictionary[key] = object;
}

- (void)encodeInteger:(NSInteger)integer forKey:(NSString *)key {
    self.dictionary[key] = @(integer);
}


@end
