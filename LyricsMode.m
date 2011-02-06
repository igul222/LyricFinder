//
//  LyricsMode.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricsMode.h"
#import "LyricDownloader.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"

@implementation LyricsMode

+(NSString *)siteName {
    return @"LyricsMode";
}

+(BOOL)matchesURL:(NSURL *)url {
    return ([[url absoluteString] rangeOfString:@"lyricsmode.com"].location != NSNotFound);
}

+(NSString *)scrapeURL:(NSURL *)url {
    NSString *response = [LyricDownloader downloadURL:url];
    if(response==nil)
        return nil;
    
	HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:nil];
    NSString *pageText = [[parser body] rawContents];
    
    NSArray *parts = [pageText componentsSeparatedByString:@"<!-- SONG LYRICS -->"];
	if([parts count] < 2)
        return nil;
    pageText = [parts objectAtIndex:1];
    
    parts = [pageText componentsSeparatedByString:@"<!-- /SONG LYRICS -->"];
	if([parts count] < 2)
        return nil;
    pageText = [parts objectAtIndex:0];
    
    // strip HTML tags
    pageText = [pageText stringByReplacingOccurrencesOfRegex:@"<[^<>]+>" withString:@""];
    pageText = [pageText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([pageText isEqualToString:@""])
        return nil;
    else
        return pageText;
}

@end
