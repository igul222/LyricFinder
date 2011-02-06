//
//  Tests.m
//  Tests
//
//  Created by Ishaan Gulrajani on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tests.h"
#import "LyricDownloader.h"

#define ASSERT_INCLUDE(haystack, needle) GHAssertTrue([haystack rangeOfString:needle].location != NSNotFound, [NSString stringWithFormat: @"String didn't contain %@!",needle]);

@implementation Tests

-(void)testFindLyrics {    
    LyricDownloader *lyricDownloader = [[LyricDownloader alloc] init];
    lyricDownloader.artist = @"U2";
    lyricDownloader.title = @"One";
    
    ASSERT_INCLUDE([lyricDownloader findLyrics], @"getting better");
}

@end
