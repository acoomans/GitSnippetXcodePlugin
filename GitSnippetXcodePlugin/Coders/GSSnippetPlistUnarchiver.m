//
//  GSSnippetPlistUnarchiver.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSSnippetPlistUnarchiver.h"

@interface GSSnippetPlistUnarchiver ()
@property (nonatomic, copy) NSDictionary *dictionary;
@end

@implementation GSSnippetPlistUnarchiver

+ (id)unarchiveObjectWithDictionary:(NSDictionary*)dictionary {
    return [[self alloc] initForReadingWithDictionary:dictionary];
}

+ (id)unarchiveObjectWithFile:(NSString*)file {
    return [self unarchiveObjectWithDictionary:[NSDictionary dictionaryWithContentsOfFile:file]];
}

- (id)initForReadingWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
    }
    return self;
}

- (id)initForReadingWithFile:(NSString*)file {
    return [self initForReadingWithDictionary:[NSDictionary dictionaryWithContentsOfFile:file]];
}

- (id)decodeObjectForKey:(NSString *)key {
    return self.dictionary[key];
}

- (BOOL)decodeBoolForKey:(NSString*)key {
    return [self.dictionary[key] boolValue];
}

- (NSInteger)decodeIntegerForKey:(NSString*)key {
    return [self.dictionary[key] integerValue];
}

@end
