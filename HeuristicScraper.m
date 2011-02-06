//
//  GenericScraper.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeuristicScraper.h"
#import "LyricDownloader.h"
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
    NSString *response = [LyricDownloader downloadURL:url];
    if(response==nil)
        return nil;
    
	HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:nil];
	NSString *pageText = [[parser body] allVisibleContents];
    
    NSString *lyrics = nil;
    
    // look for plaintext ringtone ads
    NSArray *parts = [pageText componentsSeparatedByRegex:@"send \".+\" ringtone to your cell" options:RKLCaseless range:NSMakeRange(0, [pageText length]) error:nil];
	DLog(@"Page contaings %i plaintext ringtone ads...",[parts count]-1);
    if([parts count]==3) {
        lyrics = [parts objectAtIndex:1];
        goto lyricsFound;
    }
    
    // look for tonefuse RTM javascript ads
    pageText = [[parser body] rawContents];
	
    // this actually matches a munged-up form of the script tag; libxml2 has trouble parsing the correct form.
    NSString *regex = @"<script\\s+[^>]*type\\s*=\\s*\"text\\/javascript\"[^>]*>\\s*document.write\\(\\s*'<scr'\\s*\\+\\s*'ipt\\s*type\\s*=\\s*\"text\\/javascript\"\\s*src\\s*=\\s*\"http:\\/\\/tonefuse.s3.amazonaws.com\\/clientjs\\/[a-z0-9]+-rtm.js\"\\s*>\\s*'\\s*\\+\\s*'ipt>'\\);\\s*<\\/script>";
    parts = [pageText componentsSeparatedByRegex:regex options:RKLCaseless range:NSMakeRange(0, [pageText length]) error:nil];
    DLog(@"Page contains %i tonefuse ads...",[parts count]-1);
    if([parts count]==3) {
        parser = [[HTMLParser alloc] initWithString:[parts objectAtIndex:1] error:nil];
        lyrics = [[parser doc] allVisibleContents]; 
        goto lyricsFound;
    }
        
    // lyrics still not found?
    DLog(@"Found no lyrics on the page.");
    return nil;
    
lyricsFound:
    DLog(@"Found what appear to be lyrics: %@",[lyrics preview]);
    lyrics = [lyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([lyrics length]<50)
        return nil;
    else if([lyrics rangeOfString:@"don't have the lyrics"].location != NSNotFound)
        return nil;
    else
        return lyrics;
}

@end
