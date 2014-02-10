//
//  GSSnippet.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 07/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>

/* keys */

extern NSString * const XSGSnippetKeyPrefix;

extern NSString * const XSGSnippetIdentifierKey;
extern NSString * const XSGSnippetVersionKey;
extern NSString * const XSGSnippetTitleKey;
extern NSString * const XSGSnippetSummaryKey;
extern NSString * const XSGSnippetCompletionScopesKey;
extern NSString * const XSGSnippetLanguageKey;
extern NSString * const XSGSnippetUserSnippetKey;
extern NSString * const XSGSnippetContentsKey;

/* values */

extern NSString * const IDECodeSnippetCompletionScopeClassImplementation;

extern NSString * const IDECodeSnippetLanguageObjectiveC;



@interface GSSnippet : NSObject <NSCoding>

- (id)initWithDictionaryRepresentation:(NSDictionary*)dictionary;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NSInteger version;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSArray *completionScopes;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign, getter=isUserSnippet) BOOL userSnippet;

@property (nonatomic, copy) NSString *contents;

@end
