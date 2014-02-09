//
//  GSSnippetTextArchiver.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSSnippetTextArchiver : NSCoder

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;

- (id)initForWritingWithMutableString:(NSMutableString*)string;

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
- (void)encodeObject:(id)object forKey:(NSString *)key;
- (void)encodeInteger:(NSInteger)integer forKey:(NSString *)key;

@end
