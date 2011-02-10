//
//  GlobalLogger.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GlobalLogger.h"

static NSMutableString *logString = nil;
@implementation GlobalLogger

+(void)initialize {
    if(!logString)
        logString = [[NSMutableString alloc] initWithString:@"PLEASE SELECT-ALL AND COPY THE FULL CONTENTS OF THIS TEXT BOX.\n"];
}

+(NSMutableString *)logString {
    return logString;
}

@end
