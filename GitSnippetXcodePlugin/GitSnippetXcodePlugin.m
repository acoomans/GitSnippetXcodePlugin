//
//  GitSnippetXcodePlugin.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//    Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GitSnippetXcodePlugin.h"

#import "GSConfigurationWindowController.h"
#import "GitSnippet.h"

#import "NSString+Path.h"
#import "NSTask+Extras.h"


static GitSnippetXcodePlugin *sharedPlugin;
static NSString * const pluginMenuTitle = @"Plug-ins";
NSString * const GSRemoteRepositoryURLKey = @"GSRemoteRepositoryURLKey";

@interface GitSnippetXcodePlugin()
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) GSConfigurationWindowController *configurationWindowController;
@end

@implementation GitSnippetXcodePlugin

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.
        NSMenu *pluginMenu = [self pluginMenu];
        
        if (pluginMenu) {
            NSMenuItem *actionMenuItem = nil;
            
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Sync Snippets" action:@selector(syncMenuAction) keyEquivalent:@""];
            actionMenuItem.target = self;
            [pluginMenu addItem:actionMenuItem];
            
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Configure Git Repository" action:@selector(configureMenuAction) keyEquivalent:@""];
            actionMenuItem.target = self;
            [pluginMenu addItem:actionMenuItem];
            
            [pluginMenu addItem:[NSMenuItem separatorItem]];
        }
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (NSString*)snippetDirectoryPath {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *snippetDirectoryPath = [NSString pathWithComponents:@[libraryPath, @"Developer", @"Xcode", @"UserData", @"CodeSnippets"]];
    return snippetDirectoryPath;
}

- (void)setRemoteRepositoryURL:(NSURL*)snippetRemoteRepositoryURL {
    [[NSUserDefaults standardUserDefaults] setURL:snippetRemoteRepositoryURL forKey:GSRemoteRepositoryURLKey];
}

- (NSURL*)remoteRepositoryURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:GSRemoteRepositoryURLKey];
}


- (NSString*)localRepositoryPath {
    return [NSString pathWithComponents:@[self.snippetDirectoryPath, @"git"]];
}

#pragma mark - Menu and actions

- (NSMenu*)pluginMenu {
    NSMenu *pluginMenu = [[[NSApp mainMenu] itemWithTitle:pluginMenuTitle] submenu];
    if (!pluginMenu) {
        pluginMenu = [[NSMenu alloc] initWithTitle:pluginMenuTitle];
        
        NSMenuItem *pluginMenuItem = [[NSMenuItem alloc] initWithTitle:pluginMenuTitle action:nil keyEquivalent:@""];
        pluginMenuItem.submenu = pluginMenu;
        
        [[NSApp mainMenu] addItem:pluginMenuItem];
    }
    return pluginMenu;
}


#pragma mark - Actions

- (void)configureMenuAction {
    self.configurationWindowController = [[GSConfigurationWindowController alloc] initWithWindowNibName:NSStringFromClass(GSConfigurationWindowController.class)];
    self.configurationWindowController.window.delegate = self;
    [self.configurationWindowController.window makeKeyWindow];
}

- (void)syncMenuAction {
    [self initializeLocalRepository];
    [self copySnippetsToLocalRepository];
    [self updateLocalWithRemoteRepository];
    [self removeAllSnippets];
    [self copySnippetsFromLocalRepository];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    self.configurationWindowController = nil;
}

#pragma mark -

- (void)initializeLocalRepository {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.localRepositoryPath]) {
        /*
         NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.localRepositoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        //NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"init", self.localRepositoryPath]];

        [task waitUntilExit];
         */
        NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"clone", self.remoteRepositoryURL.absoluteString, self.localRepositoryPath]];
        [task waitUntilExit];
    }
}

- (void)updateLocalWithRemoteRepository {
    
    NSTask *task;
    
    task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"add", @"--all", @"."]
                       inCurrentDirectoryPath:self.localRepositoryPath];
    [task waitUntilExit];
    
    task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"commit", @"--allow-empty-message", @"-m", @""]
                       inCurrentDirectoryPath:self.localRepositoryPath];
    [task waitUntilExit];
    
    task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"pull", @"-s", @"recursive", @"-X", @"ours", @"--no-commit"]
                       inCurrentDirectoryPath:self.localRepositoryPath];
    [task waitUntilExit];
    
    if (task.terminationStatus != 0) {
        task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"pull", @"-s", @"ours", @"--no-commit"]
                           inCurrentDirectoryPath:self.localRepositoryPath];
        [task waitUntilExit];
    }
    
    task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"commit", @"--allow-empty-message", @"-m", @""]
                       inCurrentDirectoryPath:self.localRepositoryPath];
    [task waitUntilExit];
    
    task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"push"]
                       inCurrentDirectoryPath:self.localRepositoryPath];
    [task waitUntilExit];
}

- (void)removeAllSnippets {
    NSError *error = nil;
    for (NSString *plistFilename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self snippetDirectoryPath] error:&error]) {
        NSString *plistPath = [[self snippetDirectoryPath] stringByAppendingPathComponent:plistFilename];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&isDirectory];
        
        if (!isDirectory && [plistFilename hasSuffix:@".codesnippet"]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error];
        }
    }
}

- (void)copySnippetsToLocalRepository {
    NSError *error = nil;
    for (NSString *plistFilename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self snippetDirectoryPath] error:&error]) {
        NSString *plistPath = [[self snippetDirectoryPath] stringByAppendingPathComponent:plistFilename];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&isDirectory];
        
        if (!isDirectory && [plistFilename hasSuffix:@".codesnippet"]) {
            
            GSSnippet *snippet = [[GSSnippet alloc] initWithCoder:[GSSnippetPlistUnarchiver unarchiveObjectWithFile:plistPath]];
            
            NSString *textFilename =  [[[[snippet.title lowercaseString] stringByAppendingString:@".m"] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringBySanitizingFilename];
            NSString *textPath = [NSString pathWithComponents:@[[self snippetDirectoryPath], @"git", textFilename]];
            
            [GSSnippetTextArchiver archiveRootObject:snippet toFile:textPath];
        }
    }
}

- (void)copySnippetsFromLocalRepository {
    
    NSError *error = nil;
    for (NSString *textFilename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.localRepositoryPath
                                                                                       error:&error]) {
        
        NSString *textPath = [self.localRepositoryPath stringByAppendingPathComponent:textFilename];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:textPath isDirectory:&isDirectory];
        
        if (!isDirectory && ![textFilename hasPrefix:@"."]) {
            
            @try {
                GSSnippet *snippet = [[GSSnippet alloc] initWithCoder:[GSSnippetTextUnarchiver unarchiveObjectWithFile:textPath]];
                
                NSString *plistFilename =  [[snippet.identifier uppercaseString] stringByAppendingString:@".codesnippet"];
                NSString *plistPath = [NSString pathWithComponents:@[self.snippetDirectoryPath, plistFilename]];
                
                [GSSnippetPlistArchiver archiveRootObject:snippet toFile:plistPath];
            }
            @catch (NSException *e) {
            }
        }
    }
}

@end
