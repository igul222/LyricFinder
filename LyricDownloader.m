//
//  LyricDownloader.m
//  LyricDownloader
//
//  Created by Ishaan Gulrajani on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricDownloader.h"
#import "ASIHTTPRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "NSDictionary_JSONExtensions.h"
#import "NSString+IG_URLEscape.h"

@interface NSMutableArray (ArchUtils_Shuffle)
- (void)shuffle;
@end

// Unbiased random rounding thingy.
static NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
	
    do {
        m <<= 1;
    } while(m < n);
	
    NSUInteger ret;
	
    do {
        ret = random() % m;
    } while(ret >= n);
	
    return ret;
}

@implementation NSMutableArray (ArchUtils_Shuffle)

- (void)shuffle {
    // http://en.wikipedia.org/wiki/Knuth_shuffle
	
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

@end

@interface LyricDownloader (PrivateMethods)

-(NSString *)bing;

-(NSArray *)scrapers;
-(NSString *)lyricWiki;
-(NSString *)lyricWikiWithURL:(NSString *)url;
-(NSString *)lyricsDotCom;
-(NSString *)lyricsDotComWithURL:(NSString *)url;

-(NSArray *)heuristicBlacklist;
-(NSString *)heuristicWithURL:(NSString *)url;

+(NSString *)urlEncodeString:(NSString *)string;

@end

@implementation LyricDownloader
@synthesize artist, title;

#pragma mark -
#pragma mark Controller

-(NSString *)findLyrics {
	DLog(@"Finding lyrics for {%@,%@}...",artist,title);
	
	NSMutableArray *shuffledScrapers = [NSMutableArray arrayWithArray:[self scrapers]];
	[shuffledScrapers shuffle];
	
	NSUInteger max = ([shuffledScrapers count] > 3 ? 3 : [shuffledScrapers count]);
	for(int i=0;i<max;i++) {		
		NSArray *scraper = [shuffledScrapers objectAtIndex:i];
		
		DLog("Attempting to scrape lyrics from %@...",[scraper objectAtIndex:2]);
		NSString *result = [self performSelector:NSSelectorFromString([scraper objectAtIndex:2])];
		
		if(result) {
			DLog(@"Returning lyrics from %@: \"%@\"... (%i chars)",[scraper objectAtIndex:2],([result length] > 15 ? [[result substringToIndex:15] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] : result),[result length]);
			return result;
		}
	}
	
	NSString *bing = [self bing];
	if(bing) {
		DLog(@"Returning lyrics from Bing meta-scraper: \"%@\"... (%i chars)",([bing length] > 15 ? [[bing substringToIndex:15] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] : bing),[bing length]);
		return bing;
	}
	else {
		DLog(@"Could not find lyrics; returning nil!");
		return nil;
	}
}

#pragma mark -
#pragma mark Meta-scrapers

-(NSString *)bing {	
	if([title isEqualToString:@""] || [[title lowercaseString] rangeOfRegex:@"track [0-9]+"].location != NSNotFound)
		return nil; // there's no way we're getting lyrics without a song title
	
	NSString *theArtist = [artist lowercaseString];
	if([theArtist rangeOfString:@"unknown artist"].location != NSNotFound)
		theArtist = @"";
	else if([theArtist rangeOfString:@"various artists"].location != NSNotFound)
		theArtist = @"";
	
	NSString *bingURL = [NSString stringWithFormat:@"http://api.search.live.net/json.aspx?Appid=%@&query=%@%%20%@%%20lyrics&sources=web",
						 @"0022853BF8944835704C9A7E02E9F6601F814624", // Bing Appid
						 [LyricDownloader urlEncodeString:theArtist],
						 [LyricDownloader urlEncodeString:title]];
	
	DLog(@"Getting Bing results with query URL: %@",bingURL);
	
	NSString *bingResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:bingURL] encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *bingJSON = [NSDictionary dictionaryWithJSONString:bingResponse error:nil];
	
	NSArray *results = [[[bingJSON objectForKey:@"SearchResponse"] objectForKey:@"Web"] objectForKey:@"Results"];
	
	// if the results contain a site we have a scraper for (in order of preference), use that
	NSArray *scrapers = [self scrapers];
	for(NSArray *scraper in scrapers) {
		for(NSDictionary *result in results) {
			NSString *url = [result objectForKey:@"Url"];
			if([url rangeOfString:[scraper objectAtIndex:0]].location != NSNotFound) {
				SEL selector = NSSelectorFromString([scraper objectAtIndex:1]);
				NSString *result = [self performSelector:selector withObject:url];
				
				if(result) {
					DLog(@"Bing meta-scraper returning lyrics from %@: \"%@\"... (%i chars)",[scraper objectAtIndex:2],([result length] > 15 ? [[result substringToIndex:15] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] : result),[result length]);
					return result;
				}
			}
		}
	}
	
	// if not, try the heuristic scraper on each result
	for(NSDictionary *result in results) {
		NSString *url = [result objectForKey:@"Url"];
				
		BOOL siteIsBlacklisted = NO;
		for(NSString *badSite in [self heuristicBlacklist]) {
			if([url rangeOfString:badSite].location != NSNotFound) {
				siteIsBlacklisted = YES;
			}
		}
		if(siteIsBlacklisted) {
			DLog(@"Heuristic scraper skipping blacklisted URL %@",url);			
			continue;
		} else {
			DLog(@"Attempting heuristic scrape on %@...",url);
		}
		
		NSString *lyrics = [self heuristicWithURL:url];
		if(lyrics) {
			DLog(@"Bing meta-scraper returning lyrics from heuristic scraper (URL: %@)...",url);
			return lyrics;
		}
	}
	
	DLog(@"Bing meta-scraper could not find lyrics; returning nil!");
	return nil;
}

#pragma mark -
#pragma mark Website scrapers

-(NSArray *)scrapers {
	// a scraper mentioned twice here gets twice the usual priority in the normal scraper checks
	// the order of this array is used to choose priority in bing meta-searches
	return [NSArray arrayWithObjects:
			[NSArray arrayWithObjects:@"http://www.lyrics.com/",@"lyricsDotComWithURL:",@"lyricsDotCom",nil],
			[NSArray arrayWithObjects:@"http://lyrics.wikia.com/",@"lyricWikiWithURL:",@"lyricWiki",nil],
			nil];
}

#pragma mark LyricWiki

-(NSString *)lyricWiki {
	NSString *url = [NSString stringWithFormat:@"http://lyrics.wikia.com/%@:%@",
					 [LyricDownloader urlEncodeString:artist], 
					 [LyricDownloader urlEncodeString:title]];
	
	return [self lyricWikiWithURL:url];
}

-(NSString *)lyricWikiWithURL:(NSString *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	
	[request startSynchronous];
	if([request error]) return nil;
	
	HTMLParser *parser = [[HTMLParser alloc] initWithString:[request responseString] error:nil];
	HTMLNode *node = [[parser body] findChildWithAttribute:@"class" matchingName:@"lyricbox" allowPartial:NO];
    [parser release];
    
	if(node==nil)
		return nil;
	else if([[node rawContents] rangeOfString:@"Category:Instrumental"].location != NSNotFound)
		return @"(Instrumental)";
	else
		return [node visibleContents];	
}

#pragma mark Lyrics.com

-(NSString *)lyricsDotCom {
	NSString *formattedArtist = [artist lowercaseString];
	formattedArtist = [formattedArtist stringByReplacingOccurrencesOfRegex:@"[^a-z0-9\\s]" withString:@""];
	formattedArtist = [formattedArtist stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@"-"];
	
	NSString *formattedTitle = [title lowercaseString];
	formattedTitle = [formattedTitle stringByReplacingOccurrencesOfRegex:@"[^a-z0-9\\s]" withString:@""];
	formattedTitle = [formattedTitle stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@"-"];
	
	NSString *url = [NSString stringWithFormat:@"http://www.lyrics.com/%@-lyrics-%@.html",formattedTitle,formattedArtist];
	
	return [self lyricsDotComWithURL:url];
}

-(NSString *)lyricsDotComWithURL:(NSString *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	
	[request startSynchronous];
	if([request error]) return nil;
	
	HTMLParser *parser = [[HTMLParser alloc] initWithString:[request responseString] error:nil];
	HTMLNode *node = [[parser body] findChildWithAttribute:@"id" matchingName:@"lyric_space" allowPartial:NO];
	
	if([node visibleContents]==nil)
		return nil;
	else
		return [[node visibleContents] stringByReplacingOccurrencesOfRegex:@"\\n---[\\s\\S]*$" withString:@""];	
}

#pragma mark -
#pragma mark Heuristic scraper

-(NSArray *)heuristicBlacklist {
	return [NSArray arrayWithObjects:
			@"beemp3",
			@"amazon",
			@"youtube",
			@"yahoo",
			@"torrent",
			@"last.fm",
			@"mp3raid",
			@"itunes",
			@"rhapsody.com",
			@"wikipedia",
			nil];
}

-(NSString *)heuristicWithURL:(NSString *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	
	[request startSynchronous];
	if([request error]) return nil;
	
	HTMLParser *parser = [[HTMLParser alloc] initWithString:[request responseString] error:nil];
	NSString *pageText = [[parser body] allVisibleContents];
	[parser release];
    
	NSArray *parts = [pageText componentsSeparatedByRegex:@"send \".+\" ringtone to your cell" options:RKLCaseless range:NSMakeRange(0, [pageText length]) error:nil];
	
	// the lyrics are most likely between the two ringtone ads, so make sure there are exactly two of them.
	if([parts count]!=3) {
		return nil;
	}
	
	NSString *lyrics = [parts objectAtIndex:1];
	lyrics = [lyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if([lyrics length]<50)
		return nil;
	else if([lyrics rangeOfString:@"don't have the lyrics"].location != NSNotFound)
		return nil;
	else
		return lyrics;
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

+(NSString *)urlEncodeString:(NSString *)string {
	return [string urlEncoded];
}

@end