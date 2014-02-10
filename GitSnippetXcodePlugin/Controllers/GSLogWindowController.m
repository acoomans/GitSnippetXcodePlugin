//
//  GSLogWindowController.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "GSLogWindowController.h"

@interface GSLogWindowController ()

@end

@implementation GSLogWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self reloadData];
}

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(textForlogWindowController:)]) {
        self.logTextView.string = [self.delegate textForlogWindowController:self];
    }
}

@end
