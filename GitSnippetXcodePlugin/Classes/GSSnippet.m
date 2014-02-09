//
//  GSSnippet.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSSnippet.h"

/* keys */

NSString * const XSGSnippetKeyPrefix = @"IDECodeSnippet";

NSString * const XSGSnippetIdentifierKey = @"IDECodeSnippetIdentifier";
NSString * const XSGSnippetVersionKey = @"IDECodeSnippetVersion";
NSString * const XSGSnippetTitleKey = @"IDECodeSnippetTitle";
NSString * const XSGSnippetSummaryKey = @"IDECodeSnippetSummary";
NSString * const XSGSnippetCompletionScopesKey = @"IDECodeSnippetCompletionScopes";
NSString * const XSGSnippetLanguageKey = @"IDECodeSnippetLanguage";
NSString * const XSGSnippetUserSnippetKey = @"IDECodeSnippetUserSnippet";
NSString * const XSGSnippetContentsKey = @"IDECodeSnippetContents";

/* values */

NSString * const IDECodeSnippetCompletionScopeClassImplementation = @"ClassImplementation";

NSString * const IDECodeSnippetLanguageObjectiveC = @"Xcode.SourceCodeLanguage.Objective-C";


@implementation GSSnippet

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.version = 1;
        
        self.title = @"";
        
        self.completionScopes = @[IDECodeSnippetCompletionScopeClassImplementation];
        self.language = IDECodeSnippetLanguageObjectiveC;
        self.userSnippet = YES;
        
        self.contents = @"";
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.identifier forKey:XSGSnippetIdentifierKey];
    [encoder encodeInteger:self.version forKey:XSGSnippetVersionKey];
    
    [encoder encodeObject:self.title forKey:XSGSnippetTitleKey];
    [encoder encodeObject:self.summary forKey:XSGSnippetSummaryKey];
    
    [encoder encodeObject:self.completionScopes forKey:XSGSnippetCompletionScopesKey];
    [encoder encodeObject:self.language forKey:XSGSnippetLanguageKey];
    [encoder encodeBool:self.userSnippet forKey:XSGSnippetUserSnippetKey];

    [encoder encodeObject:self.contents forKey:XSGSnippetContentsKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.identifier = [decoder decodeObjectForKey:XSGSnippetIdentifierKey];
        self.version = [decoder decodeIntegerForKey:XSGSnippetVersionKey];
        
        self.title = [decoder decodeObjectForKey:XSGSnippetTitleKey];
        self.summary = [decoder decodeObjectForKey:XSGSnippetSummaryKey];
        
        self.completionScopes = [decoder decodeObjectForKey:XSGSnippetCompletionScopesKey];
        self.language = [decoder decodeObjectForKey:XSGSnippetLanguageKey];
        self.userSnippet = [decoder decodeBoolForKey:XSGSnippetUserSnippetKey];
        
        self.contents = [decoder decodeObjectForKey:XSGSnippetContentsKey];
    }
    return self;
}

@end
