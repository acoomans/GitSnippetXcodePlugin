//
//  NSTask+Extras.h
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (Extras)

+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments inCurrentDirectoryPath:(NSString*)directoryPath;

@end
