//
//  HindiLyrix.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HindiLyrix.h"
#import "LyricDownloader.h"
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
    NSString *response = [LyricDownloader downloadURL:url];
    if(response==nil)
        return nil;
    
	HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:nil];
	HTMLNode *node = [[parser body] findChildTag:@"pre"];
    node = [node findChildTag:@"font"];
    
	if([node allVisibleContents]==nil)
		return nil;
	else
		return [[node visibleContents] stringByReplacingOccurrencesOfRegex:@"\\n---[\\s\\S]*$" withString:@""];	
}

@end
