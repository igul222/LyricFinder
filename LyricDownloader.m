//
//  LyricDownloader.m
//  LyricDownloader
//
//  Created by Ishaan Gulrajani on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricDownloader.h"
#import "LyricSite.h"
#import "NSString+LyricFinder.h"

@implementation LyricDownloader
@synthesize artist, title;

-(NSString *)findLyrics {
	DLog(@"Finding lyrics for {%@,%@}...",artist,title);
	
	for(NSString *searcherName in [LyricDownloader searchers]) {		
        Class searcher = NSClassFromString(searcherName);
		
		DLog(@"Attempting to search for lyrics at %@...",[searcher siteName]);
		NSString *lyrics = [searcher searchForTitle:self.title artist:self.artist];
		
		if(lyrics) {
			DLog(@"Returning lyrics from %@: \"%@\"... (%i chars)",[searcher siteName],[lyrics preview],[lyrics length]);
			return lyrics;
		}
	}
    
    return nil;
}

#pragma mark -
#pragma mark Website scrapers

+(NSArray *)searchers {
    // LyricsDotCom can search, but it's too slow to be useful, so we use it only as a scraper
    return [NSArray arrayWithObjects:@"LyricWiki",@"Bing",nil];
}

+(NSArray *)scrapers {
	return [NSArray arrayWithObjects:@"LyricWiki",@"LyricsDotCom",@"HindiLyrix",@"HeuristicScraper",@"LyricsMode",nil];
}

#pragma mark -
#pragma mark Miscellaneous

-(void)setArtist:(NSString *)newArtist {
    if (artist != newArtist) {
        [artist release];
        artist = [[newArtist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy];
    }
}

-(void)setTitle:(NSString *)newTitle {
    if (title != newTitle) {
        [title release];
        title = [[newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy];
    }
}

@end