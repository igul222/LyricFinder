//
//  NSString+IG_URLEscape.m
//  Lyric Finder
//
//  Created by Ishaan Gulrajani on 2/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+LyricFinder.h"


@implementation NSString (LyricFinder)

-(NSString *)URLEncoded {
	NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				  NULL,
																				  (CFStringRef)self,
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8);
	return encodedString;	
}

-(NSString *)preview {
    if([self length] < 20)
        return self;
    
    NSString *result = [NSString stringWithFormat:@"%@%@",[self substringToIndex:15],@"..."];
    return [result stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
}

@end
