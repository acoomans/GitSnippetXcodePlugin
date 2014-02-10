//
//  GitSnippetXcodePlugin.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface GitSnippetXcodePlugin : NSObject <NSWindowDelegate>

@property (nonatomic, strong) NSURL *remoteRepositoryURL;
@property (nonatomic, strong) NSString *localRepositoryPath;
@property (nonatomic, strong) NSString *snippetDirectoryPath;

- (void)initializeLocalRepository;
- (void)updateLocalWithRemoteRepository;
- (void)removeAllSnippets;
- (void)copySnippetsToLocalRepository;
- (void)copySnippetsFromLocalRepository;

@end