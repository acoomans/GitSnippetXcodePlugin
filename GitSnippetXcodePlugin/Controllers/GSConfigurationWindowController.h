//
//  GSConfigurationWindowController.h
//  XcodeSnippetGit
//
//  Created by Arnaud Coomans on 06/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GSConfigurationWindowController : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *remoteRepositoryTextfield;

@end
