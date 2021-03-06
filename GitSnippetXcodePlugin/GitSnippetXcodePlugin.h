//
//  GitSnippetXcodePlugin.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "GSConfigurationWindowController.h"
#import "GSLogWindowController.h"

#import "GitSnippet.h"

#import "NSString+Path.h"
#import "NSTask+Extras.h"

@class GSSnippet;


@interface GitSnippetXcodePlugin : NSObject <NSWindowDelegate, GSLogWindowControllerDataSource>

+ (instancetype)sharedPlugin;

@property (nonatomic, strong) NSURL *remoteRepositoryURL;
@property (nonatomic, strong) NSString *localRepositoryPath;
@property (nonatomic, strong) NSString *snippetDirectoryPath;
@property (nonatomic, copy) NSString *taskLog;

- (void)initializeLocalRepository;
- (void)updateLocalWithRemoteRepository;
- (void)removeAllSnippets;
- (void)copySnippetsToLocalRepository;
- (void)copySnippetsFromLocalRepository;

- (void)addSnippetToLocalRepository:(GSSnippet*)snippet;
- (void)removeSnippetFromLocalRepository:(GSSnippet*)snippet;

@end