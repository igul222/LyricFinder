//
//  NSString+IG_URLEscape.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+IG_URLEscape.h"


@implementation NSString (IG_URLEscape)

-(NSString *)urlEncoded {
	NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				  NULL,
																				  (CFStringRef)self,
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
	return encodedString;	
}

@end
