//
//  GenericScraper.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeuristicScraper.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"
#import "HTMLParser.h"
#import "NSString+LyricFinder.h"

@implementation HeuristicScraper

+(NSString *)siteName {
    return @"Heuristic scraper";
}

+(BOOL)matchesURL:(NSURL *)url {
    // a bunch of sites that commonly show up in lyric search results, but never contain lyrics.
    NSArray *blacklist = [NSArray arrayWithObjects:
                          @"beemp3",
                          @"amazon",
                          @"youtube",
                          @"yahoo",
                          @"torrent",
                          @"last.fm",
                          @"mp3raid",
                          @"itunes",
                          @"rhapsody",
                          @"wikipedia",
                          nil];
    
    NSString *urlString = [url absoluteString];
    for(NSString *keyword in blacklist) {
        if([urlString rangeOfString:keyword].location != NSNotFound)
            return NO;
    }
    
    return YES;
}

+(NSString *)scrapeURL:(NSURL *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	[request startSynchronous];
	if([request error])
        return nil;
	
    DLog(@"Downloaded page: %i chars long...",[[request responseString] length]);
    
	HTMLParser *parser = [[HTMLParser alloc] initWithString:[request responseString] error:nil];
	NSString *pageText = [[parser body] allVisibleContents];
    
	NSArray *parts = [pageText componentsSeparatedByRegex:@"send \".+\" ringtone to your cell" options:RKLCaseless range:NSMakeRange(0, [pageText length]) error:nil];
	
	// the lyrics are most likely between the two ringtone ads, so make sure there are exactly two of them.
	DLog(@"Page contaings %i ringtone ads...",[parts count]-1);
    if([parts count]!=3)
		return nil;
	
	NSString *lyrics = [parts objectAtIndex:1];
	lyrics = [lyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
    DLog(@"Found what appear to be lyrics: %@",[lyrics preview]);
    
	if([lyrics length]<50)
		return nil;
	else if([lyrics rangeOfString:@"don't have the lyrics"].location != NSNotFound)
		return nil;
	else
		return lyrics;
}

@end
