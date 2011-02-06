//
//  Bing.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bing.h"
#import "RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "NSString+LyricFinder.h"
#import "NSDictionary_JSONExtensions.h"
#import "LyricDownloader.h"

#define BING_APPID @"0022853BF8944835704C9A7E02E9F6601F814624"

@implementation Bing

+(NSString *)siteName {
    return @"Bing meta-scraper";
}

+(NSString *)searchForTitle:(NSString *)title artist:(NSString *)artist {
    if([title isEqualToString:@""] || [[title lowercaseString] rangeOfRegex:@"track [0-9]+"].location != NSNotFound)
		return nil; // there's no way we're getting lyrics here without a song title
	
	artist = [artist lowercaseString];
	if([artist rangeOfString:@"unknown artist"].location != NSNotFound)
		artist = @"";
	else if([artist rangeOfString:@"various artists"].location != NSNotFound)
		artist = @"";
	
	NSString *bingURL = [NSString stringWithFormat:@"http://api.search.live.net/json.aspx?Appid=%@&query=%@%%20%@%%20lyrics&sources=web",
						 BING_APPID, // Bing Appid
						 [artist URLEncoded],
						 [title URLEncoded]];
	
	DLog(@"Getting Bing results with query URL: %@",bingURL);
	
	NSString *bingResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:bingURL] encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *bingJSON = [NSDictionary dictionaryWithJSONString:bingResponse error:nil];
	
	NSArray *results = [[[bingJSON objectForKey:@"SearchResponse"] objectForKey:@"Web"] objectForKey:@"Results"];
	
	for(NSString *scraperName in [LyricDownloader scrapers]) {
		Class scraper = NSClassFromString(scraperName);
        
        DLog(@"Evaluating results against scraper: %@",[scraper siteName]);
        for(NSDictionary *result in results) {
			NSURL *url = [NSURL URLWithString:[result objectForKey:@"Url"]];
        
            if([scraper matchesURL:url]) {
                NSString *lyrics = [scraper scrapeURL:url];        
                if(lyrics) {
					DLog(@"Bing meta-searcher returning lyrics from %@: \"%@\"... (%i chars)",[scraper siteName],[lyrics preview],[lyrics length]);
					return lyrics;
                }
            }
		}
	}

	DLog(@"Bing meta-searcher could not find lyrics; returning nil!");
	return nil;
}

@end
