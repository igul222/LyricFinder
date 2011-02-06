//
//  LyricScraper.h
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LyricSite <NSObject>

// required for everyone
+(NSString *)siteName;

@optional

// required for searchers
+(NSString *)searchForTitle:(NSString *)title artist:(NSString *)artist;

// required for scrapers
+(BOOL)matchesURL:(NSURL *)url;
+(NSString *)scrapeURL:(NSURL *)url;

@end
