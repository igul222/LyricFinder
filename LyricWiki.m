//
//  LyricWiki.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricWiki.h"
#import "LyricDownloader.h"
#import "NSString+LyricFinder.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"

@implementation LyricWiki

+(NSString *)siteName {
    return @"LyricWiki";
}

+(BOOL)matchesURL:(NSURL *)url {
    return ([[url absoluteString] rangeOfString:@"http://lyrics.wikia.com"].location != NSNotFound);
}

+(NSString *)searchForTitle:(NSString *)title artist:(NSString *)artist {
    NSString *url = [NSString stringWithFormat:@"http://lyrics.wikia.com/%@:%@",
					 [artist URLEncoded], 
					 [title URLEncoded]];
	
	return [LyricWiki scrapeURL:[NSURL URLWithString:url]];
}

+(NSString *)scrapeURL:(NSURL *)url {	    
    NSString *response = [LyricDownloader downloadURL:url];
    if(response==nil)
        return nil;
    
	HTMLParser *parser = [[HTMLParser alloc] initWithString:response error:nil];
	HTMLNode *node = [[parser body] findChildWithAttribute:@"class" matchingName:@"lyricbox" allowPartial:NO];
        
	if(node==nil)
		return nil;
	else if([[node rawContents] rangeOfString:@"Category:Instrumental"].location != NSNotFound)
		return @"(Instrumental)";
	else
		return [node visibleContents];
}

@end
