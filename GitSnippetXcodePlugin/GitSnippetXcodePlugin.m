//
//  GitSnippetXcodePlugin.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//    Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GitSnippetXcodePlugin.h"

#import "swizzling.h" // da magic book
#import "IDECodeSnippet.h"
#import "IDECodeSnippetRepository.h"


static GitSnippetXcodePlugin *shareGitSnippetXcodePlugin;
static NSString * const pluginMenuTitle = @"Plug-ins";
NSString * const GSRemoteRepositoryURLKey = @"GSRemoteRepositoryURLKey";



// gettin doppelgangers ready

void override_IDECodeSnippetRepository_saveUserCodeSnippetToDisk(id self, SEL _cmd, id arg1) {

    [(IDECodeSnippetRepository*)self old_saveUserCodeSnippetToDisk:arg1];
    
    GSSnippet *snippet = [[GSSnippet alloc] initWithDictionaryRepresentation:[arg1 dictionaryRepresentation]];
    
    
    NSLog(@"%@ %@", snippet.title, snippet.identifier);
    NSLog(@"%@", [GitSnippetXcodePlugin sharedPlugin]);
    NSLog(@"%@", [GitSnippetXcodePlugin sharedPlugin].remoteRepositoryURL);
    NSLog(@"%@", snippet.isUserSnippet?@"YES":@"NO");
    
    
    
    if ([GitSnippetXcodePlugin sharedPlugin].remoteRepositoryURL && snippet.isUserSnippet) {
        
        [[GitSnippetXcodePlugin sharedPlugin] initializeLocalRepository];
        [[GitSnippetXcodePlugin sharedPlugin] addSnippetToLocalRepository:snippet];
        [[GitSnippetXcodePlugin sharedPlugin] updateLocalWithRemoteRepository];
    }

    
    /*
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        // fool the guards
        GSSnippet *snippet = (GSSnippet*)arg1;
        NSLog(@"%@ %@", snippet.title, snippet.identifier);
        NSLog(@"%@", [GitSnippetXcodePlugin sharedPlugin]);
        NSLog(@"%@", [GitSnippetXcodePlugin sharedPlugin].remoteRepositoryURL);
        NSLog(@"%@", snippet.isUserSnippet?@"YES":@"NO");
        
        if ([GitSnippetXcodePlugin sharedPlugin].remoteRepositoryURL && snippet.isUserSnippet) {
            NSLog(@"Adding snippet \"%@\" (%@) to repository", [arg1 title], [arg1 identifier]);
            
            [[GitSnippetXcodePlugin sharedPlugin] initializeLocalRepository];
            [[GitSnippetXcodePlugin sharedPlugin] addSnippetToLocalRepositoryWithIdentifier:[arg1 identifier]];
            [[GitSnippetXcodePlugin sharedPlugin] updateLocalWithRemoteRepository];
        }
    });*/
    
    
}

void override_IDECodeSnippetRepository_removeCodeSnippet(id self, SEL _cmd, id arg1) {
    
    
    GSSnippet *snippet = [[GSSnippet alloc] initWithDictionaryRepresentation:[arg1 dictionaryRepresentation]];
    
    if ([GitSnippetXcodePlugin sharedPlugin].remoteRepositoryURL && snippet.isUserSnippet) {
        
        [[GitSnippetXcodePlugin sharedPlugin] initializeLocalRepository];
        [[GitSnippetXcodePlugin sharedPlugin] removeSnippetFromLocalRepository:snippet];
        [[GitSnippetXcodePlugin sharedPlugin] updateLocalWithRemoteRepository];
        
        /*
        NSLog(@"Removing snippet \"%@\" (%@) to repository", [arg1 title], [arg1 identifier]);
        
        [[GitSnippetXcodePlugin sharedPlugin] initializeLocalRepository];
        [[GitSnippetXcodePlugin sharedPlugin] removeSnippetFromLocalRepositoryWithIdentifier:[arg1 identifier]];
        [[GitSnippetXcodePlugin sharedPlugin] updateLocalWithRemoteRepository];
         */
    }
    
    [(IDECodeSnippetRepository*)self old_removeCodeSnippet:arg1];
}



@interface GitSnippetXcodePlugin()
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) GSConfigurationWindowController *configurationWindowController;
@property (nonatomic, strong) GSLogWindowController *logWindowController;
@end

@implementation GitSnippetXcodePlugin


+ (instancetype)sharedPlugin {
    return shareGitSnippetXcodePlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            shareGitSnippetXcodePlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)init {
    return [self initWithBundle:nil];
}


- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        
        // summon the snippets repository from the bundle
        
        [[NSBundle bundleWithIdentifier:@"com.apple.dt.IDE.IDECodeSnippetLibrary"] load];
        Class cls = NSClassFromString(@"IDECodeSnippetRepository");
        
        // teleport the doppelgangers in the royal court
        
        MethodSwizzleWithIMP(cls, NSSelectorFromString(@"saveUserCodeSnippetToDisk:"), NSSelectorFromString(@"old_saveUserCodeSnippetToDisk:"), (IMP)override_IDECodeSnippetRepository_saveUserCodeSnippetToDisk);
        MethodSwizzleWithIMP(cls, NSSelectorFromString(@"removeCodeSnippet:"), NSSelectorFromString(@"old_removeCodeSnippet:"), (IMP)override_IDECodeSnippetRepository_removeCodeSnippet);
        
        
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        self.taskLog = @"";
        
        // Create menu items, initialize UI, etc.
        NSMenu *pluginMenu = [self pluginMenu];
        
        if (pluginMenu) {
            NSMenuItem *actionMenuItem = nil;
            
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Sync Snippets" action:@selector(syncMenuAction) keyEquivalent:@""];
            actionMenuItem.target = self;
            [pluginMenu addItem:actionMenuItem];
            
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Configure Git Snippets" action:@selector(configureMenuAction) keyEquivalent:@""];
            actionMenuItem.target = self;
            [pluginMenu addItem:actionMenuItem];
            
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"View Log" action:@selector(viewLogAction) keyEquivalent:@""];
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

- (void)setTaskLog:(NSString *)taskLog {
    _taskLog = taskLog;
    [self.logWindowController reloadData];
}

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
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:GSRemoteRepositoryURLKey]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"No remote repository configured"
                                         defaultButton:nil
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@""];
        [alert runModal];
        [self configureMenuAction];
    }

    [self initializeLocalRepository];
    [self copySnippetsToLocalRepository];
    [self updateLocalWithRemoteRepository];
    [self removeAllSnippets];
    [self copySnippetsFromLocalRepository];
}

- (void)viewLogAction {
    self.logWindowController = [[GSLogWindowController alloc] initWithWindowNibName:NSStringFromClass(GSLogWindowController.class)];
    self.logWindowController.delegate = self;
    self.logWindowController.window.delegate = self;
    [self.logWindowController.window makeKeyWindow];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    
    if (notification.object == self.configurationWindowController.window) {
        self.configurationWindowController = nil;
    }

    if (notification.object == self.logWindowController.window) {
        self.logWindowController = nil;
    }
}

#pragma mark - GSLogWindowControllerDataSource

- (NSString*)textForlogWindowController:(GSLogWindowController*)logWindowController {
    return self.taskLog;
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
        NSString *output;
        [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                      arguments:@[@"clone", self.remoteRepositoryURL.absoluteString, self.localRepositoryPath]
                         inCurrentDirectoryPath:self.snippetDirectoryPath
                         standardOutputAndError:&output];
        self.taskLog = [self.taskLog stringByAppendingString:output];
    }
}

- (void)updateLocalWithRemoteRepository {
    
    NSString *output;
    
    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                  arguments:@[@"add", @"--all", @"."]
                     inCurrentDirectoryPath:self.localRepositoryPath
                     standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];
    
    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                  arguments:@[@"commit", @"--allow-empty-message", @"-m", @""]
                     inCurrentDirectoryPath:self.localRepositoryPath
                     standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];
    
    NSTask *task = [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                                 arguments:@[@"pull", @"-s", @"recursive", @"-X", @"ours", @"--no-commit"]
                                    inCurrentDirectoryPath:self.localRepositoryPath
                                    standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];

    if (task.terminationStatus != 0) {
        [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                      arguments:@[@"pull", @"-s", @"ours", @"--no-commit"]
                         inCurrentDirectoryPath:self.localRepositoryPath
                         standardOutputAndError:&output];
        self.taskLog = [self.taskLog stringByAppendingString:output];
    }
    
    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                  arguments:@[@"commit", @"--allow-empty-message", @"-m", @""]
                     inCurrentDirectoryPath:self.localRepositoryPath
                     standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];
    
    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                  arguments:@[@"push"]
                     inCurrentDirectoryPath:self.localRepositoryPath
                     standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];
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

- (void)addSnippetToLocalRepository:(GSSnippet*)snippet {
    
    NSError *error = nil;
    for (NSString *textFilename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.localRepositoryPath
                                                                                       error:&error]) {
        
        NSString *textPath = [self.localRepositoryPath stringByAppendingPathComponent:textFilename];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:textPath isDirectory:&isDirectory];
        
        if (!isDirectory && ![textFilename hasPrefix:@"."]) {
            
            @try {
                GSSnippet *s = [[GSSnippet alloc] initWithCoder:[GSSnippetTextUnarchiver unarchiveObjectWithFile:textPath]];
                
                if ([s.identifier isEqualToString:snippet.identifier]) {
                    NSString *output;
                    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                                  arguments:@[@"rm", textFilename]
                                     inCurrentDirectoryPath:self.localRepositoryPath
                                     standardOutputAndError:&output];
                    self.taskLog = [self.taskLog stringByAppendingString:output];
                }
            }
            @catch (NSException *e) {
            }
        }
    }

    NSString *textFilename =  [[[[snippet.title lowercaseString] stringByAppendingString:@".m"] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringBySanitizingFilename];
    
    NSString *textPath = [NSString pathWithComponents:@[[self snippetDirectoryPath], @"git", textFilename]];
    
    [GSSnippetTextArchiver archiveRootObject:snippet toFile:textPath];
    
    NSString *output;
    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                  arguments:@[@"add", textFilename]
                     inCurrentDirectoryPath:self.localRepositoryPath
                     standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];

}

- (void)removeSnippetFromLocalRepository:(GSSnippet*)snippet {
    
    NSString *textFilename =  [[[[snippet.title lowercaseString] stringByAppendingString:@".m"] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringBySanitizingFilename];
    
    NSString *output;
    [NSTask launchAndWaitTaskWithLaunchPath:@"/usr/bin/git"
                                  arguments:@[@"rm", textFilename]
                     inCurrentDirectoryPath:self.localRepositoryPath
                     standardOutputAndError:&output];
    self.taskLog = [self.taskLog stringByAppendingString:output];
}

@end
