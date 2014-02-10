//
//  NSTask+Extras.m
//  GitSnippetXcodePlugin
//
//  Created by Arnaud Coomans on 09/02/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import "NSTask+Extras.h"

@implementation NSTask (Extras)

+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments inCurrentDirectoryPath:(NSString*)directoryPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = path;
    task.arguments = arguments;
    task.currentDirectoryPath = directoryPath;
    [task launch];
    return task;
}

@end
