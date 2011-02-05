//
//  LyricRequest.h
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class iTunesTrack;
@interface LyricRequest : NSObject {
	NSString *artist;
	NSString *title;
	iTunesTrack *track;
	NSString *lyrics;
}
@property(copy) NSString *artist;
@property(copy) NSString *title;
@property(retain) iTunesTrack *track;
@property(copy) NSString *lyrics;

-(id)initWithTrack:(iTunesTrack *)theTrack;
-(void)fulfill;
-(BOOL)apply;

@end
