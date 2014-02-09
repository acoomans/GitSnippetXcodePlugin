//
//  GSConfigurationWindowController.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 06/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSConfigurationWindowController.h"
#import "GitSnippet.h"

@interface GSConfigurationWindowController ()
@property (nonatomic, strong) NSURL *snippetRemoteRepositoryURL;
@end

@implementation GSConfigurationWindowController

#pragma mark - Initialization 

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.remoteRepositoryTextfield.stringValue = self.snippetRemoteRepositoryURL.absoluteString?:@"";
}

#pragma mark - Properties

- (void)setSnippetRemoteRepositoryURL:(NSURL*)snippetRemoteRepositoryURL {
    [[NSUserDefaults standardUserDefaults] setURL:snippetRemoteRepositoryURL forKey:GSRemoteRepositoryURLKey];
}

- (NSURL*)snippetRemoteRepositoryURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:GSRemoteRepositoryURLKey];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    self.snippetRemoteRepositoryURL = [NSURL URLWithString:textField.stringValue];
}


@end
