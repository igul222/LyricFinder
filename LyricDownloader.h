//
//  LyricDownloader.h
//  LyricDownloader
//
//  Created by Ishaan Gulrajani on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LyricDownloader : NSObject {
	NSString *artist;
	NSString *title;
}
@property(nonatomic,copy) NSString *artist;
@property(nonatomic,copy) NSString *title;

-(NSString *)findLyrics;

+(NSArray *)searchers;
+(NSArray *)scrapers;

@end
