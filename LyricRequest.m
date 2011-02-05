//
//  LyricRequest.m
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricRequest.h"
#import "iTunes.h"
#import "LyricDownloader.h"

@implementation LyricRequest
@synthesize artist, title, track, lyrics;

-(void)dealloc {
	[artist release];
	[title release];
	[track release];
	[lyrics release];
	[super dealloc];
}

-(id)initWithTrack:(iTunesTrack *)theTrack {
	if((self = [super init])) {
		self.artist = [theTrack artist];
		self.title = [theTrack name];
		self.track = theTrack;
	}
	return self;
}

-(void)fulfill {
	LyricDownloader *downloader = [[LyricDownloader alloc] init];
	downloader.artist = self.artist;
	downloader.title = self.title;
	self.lyrics = [downloader findLyrics];
    
    [downloader release];
}

-(BOOL)apply {
	if([self.lyrics length] > 0) {
		[self.track setLyrics:self.lyrics];
		DLog(@"Applied lyrics (%i chars) to {%@,%@}",[self.lyrics length],artist,title);
		return YES;
	} else {
		DLog(@"Didn't apply lyrics (%i chars) to {%@,%@}",[self.lyrics length],artist,title);
		return NO;
	}
}

@end
