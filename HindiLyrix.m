//
//  HindiLyrix.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HindiLyrix.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"

@implementation HindiLyrix

+(NSString *)siteName {
    return @"HindiLyrix";
}

+(BOOL)matchesURL:(NSURL *)url {
    return ([[url absoluteString] rangeOfString:@"hindilyrix.com"].location != NSNotFound);
}

+(NSString *)scrapeURL:(NSURL *)url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	[request startSynchronous];
	if([request error]) return nil;
	
	HTMLParser *parser = [[HTMLParser alloc] initWithString:[request responseString] error:nil];
	HTMLNode *node = [[parser body] findChildTag:@"pre"];
    node = [node findChildTag:@"font"];
    
	if([node allVisibleContents]==nil)
		return nil;
	else
		return [[node visibleContents] stringByReplacingOccurrencesOfRegex:@"\\n---[\\s\\S]*$" withString:@""];	
}

@end
