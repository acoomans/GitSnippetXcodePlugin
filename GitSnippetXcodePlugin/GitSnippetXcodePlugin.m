//
//  GitSnippetXcodePlugin.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//    Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GitSnippetXcodePlugin.h"

#import "GSConfigurationWindowController.h"

static GitSnippetXcodePlugin *sharedPlugin;
static NSString * const pluginMenuTitle = @"Plug-ins";
NSString * const GSRemoteRepositoryURLKey = @"GSRemoteRepositoryURLKey";

@interface GitSnippetXcodePlugin()
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSURL *remoteRepositoryURL;
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
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    self.configurationWindowController = nil;
}


@end
