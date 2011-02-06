//
//  LyricsDotCom.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricsDotCom.h"
#import "RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "NSString+LyricFinder.h"

@implementation LyricsDotCom

+(NSString *)siteName {
    return @"Lyrics.com";
}

+(BOOL)matchesURL:(NSURL *)url {
    return ([[url absoluteString] rangeOfString:@"http://lyrics.com"].location != NSNotFound ||
            [[url absoluteString] rangeOfString:@"http://www.lyrics.com"].location != NSNotFound);
}

+(NSString *)searchForTitle:(NSString *)title artist:(NSString *)artist {
    NSString *formattedArtist = [artist lowercaseString];
	formattedArtist = [formattedArtist stringByReplacingOccurrencesOfRegex:@"[^a-z0-9\\s]" withString:@""];
	formattedArtist = [formattedArtist stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@"-"];
	
	NSString *formattedTitle = [title lowercaseString];
	formattedTitle = [formattedTitle stringByReplacingOccurrencesOfRegex:@"[^a-z0-9\\s]" withString:@""];
	formattedTitle = [formattedTitle stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@"-"];
	
	NSString *url = [NSString stringWithFormat:@"http://www.lyrics.com/%@-lyrics-%@.html",formattedTitle,formattedArtist];
	
    return [self scrapeURL:[NSURL URLWithString:url]];
}

+(NSString *)scrapeURL:(NSURL *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	[request startSynchronous];
	if([request error]) return nil;
	
	HTMLParser *parser = [[HTMLParser alloc] initWithString:[request responseString] error:nil];
	HTMLNode *node = [[parser body] findChildWithAttribute:@"id" matchingName:@"lyric_space" allowPartial:NO];
	
	if([node visibleContents]==nil)
		return nil;
	else
		return [[node visibleContents] stringByReplacingOccurrencesOfRegex:@"\\n---[\\s\\S]*$" withString:@""];	
}

@end
