//
//  iTunesController.h
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject {
	NSMutableArray *lyricRequests;
	NSInteger totalSongs;
	NSInteger progressFinished;
	NSInteger progressTotal;
	NSInteger successfulRequests;
	id delegate;
}
@property NSInteger totalSongs;
@property NSInteger progressFinished;
@property NSInteger progressTotal;
@property NSInteger successfulRequests;
@property(assign) id delegate;

-(void)beginWorking;
-(void)fullfillAndApplyLyricRequests;
-(void)lyricRequestFinishedSuccessfully:(BOOL)success;

@end
