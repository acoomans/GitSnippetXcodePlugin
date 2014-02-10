//
//  GitSnippetXcodePlugin_Tests.m
//  GitSnippetXcodePlugin Tests
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GitSnippet.h"
#import "GitSnippetXcodePlugin.h"

@interface GitSnippetXcodePlugin_Tests : SenTestCase
@end

@implementation GitSnippetXcodePlugin_Tests


- (void)testSync {
    
    [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:@"git@github.com:acoomans/test.git"] forKey:GSRemoteRepositoryURLKey];
    
    GitSnippetXcodePlugin *plugin = [[GitSnippetXcodePlugin alloc] init];
    
    [plugin initializeLocalRepository];
    [plugin copySnippetsToLocalRepository];
    [plugin updateLocalWithRemoteRepository];
    [plugin removeAllSnippets];
    [plugin copySnippetsFromLocalRepository];
    
    NSLog(@"%@", plugin.taskLog);
    
}

- (void)testAdd {
    
    [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:@"git@github.com:acoomans/test.git"] forKey:GSRemoteRepositoryURLKey];
    
    GitSnippetXcodePlugin *plugin = [[GitSnippetXcodePlugin alloc] init];
    
    NSError *error = nil;
    for (NSString *plistFilename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:plugin.snippetDirectoryPath error:&error]) {
        NSString *plistPath = [plugin.snippetDirectoryPath stringByAppendingPathComponent:plistFilename];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&isDirectory];
        
        if (!isDirectory && [plistFilename hasSuffix:@".codesnippet"]) {
            
            GSSnippet *snippet = [[GSSnippet alloc] initWithCoder:[GSSnippetPlistUnarchiver unarchiveObjectWithFile:plistPath]];
            
            [plugin initializeLocalRepository];
            [plugin addSnippetToLocalRepositoryWithIdentifier:snippet.identifier];
            [plugin updateLocalWithRemoteRepository];
        }
    }
    
    NSLog(@"%@", plugin.taskLog);
    
}

@end
