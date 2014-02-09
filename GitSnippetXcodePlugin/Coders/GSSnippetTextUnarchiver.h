//
//  GSSnippetTextUnarchiver.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSSnippetTextUnarchiver : NSCoder

+ (id)unarchiveObjectWithString:(NSString*)string;
+ (id)unarchiveObjectWithFile:(NSString*)file;

- (id)initForReadingWithString:(NSString*)string;
- (id)initForReadingWithFile:(NSString*)file;

- (id)decodeObjectForKey:(NSString *)key;
- (BOOL)decodeBoolForKey:(NSString*)key;
- (NSInteger)decodeIntegerForKey:(NSString*)key;

@end
