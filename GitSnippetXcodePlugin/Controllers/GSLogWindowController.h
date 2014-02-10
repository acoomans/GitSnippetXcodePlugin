//
//  GSLogWindowController.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GSLogWindowController;

@protocol GSLogWindowControllerDataSource <NSObject>
- (NSString*)textForlogWindowController:(GSLogWindowController*)logWindowController;
@end


@interface GSLogWindowController : NSWindowController

@property (nonatomic, weak) id<GSLogWindowControllerDataSource> delegate;
@property (nonatomic, strong) IBOutlet NSTextView *logTextView;
- (void)reloadData;

@end
