//
//  iTunesController.m
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "iTunes.h"
#import "LyricRequest.h"

@implementation Controller
@synthesize totalSongs, progressFinished,progressTotal,successfulRequests,delegate;

-(void)dealloc {
	[lyricRequests release];
	[super dealloc];
}

-(void)beginWorking {

	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	[iTunes run];

	// find the library
	iTunesSource *librarySource = nil;
	for(iTunesSource *source in [iTunes sources]) {
		if([source kind] == iTunesESrcLibrary) {
			librarySource = source;
			break;
		}
	}
	
	// find the main playlist
	iTunesPlaylist *musicPlaylist = nil;
	for(iTunesPlaylist *playlist in [librarySource playlists]) {
		if([[playlist name] isEqualToString:@"Music"]) {
			musicPlaylist = playlist;
		}
	}

	lyricRequests = [[NSMutableArray alloc] initWithCapacity:1000];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		for(iTunesTrack *track in [musicPlaylist tracks]) {			
			totalSongs++;
			BOOL oldLyrics = [[track lyrics] length] > 9;
			
			if(!oldLyrics) {
				LyricRequest *request = [[LyricRequest alloc] initWithTrack:track];
				[lyricRequests addObject:request];
				[request release];
				DLog(@"Queued {%@,%@}",[track artist],[track name]);
			} else {
				DLog(@"Didn't queue {%@,%@}",[track artist],[track name]);
			}
		}
		
		DLog(@"Finished queueing tracks: %i tracks in queue",lyricRequests.count);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.progressTotal = lyricRequests.count;
			[delegate performSelector:@selector(libraryScanFinished)];
			[self fullfillAndApplyLyricRequests];
		});
	});

}

-(void)fullfillAndApplyLyricRequests {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		for(LyricRequest *request in lyricRequests) {
			[request fulfill];
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				BOOL result = [request apply];
				[self lyricRequestFinishedSuccessfully:result];
			});
		}
	});	
}

-(void)lyricRequestFinishedSuccessfully:(BOOL)success {
	self.progressFinished = self.progressFinished + 1;
	if(success)
		self.successfulRequests = self.successfulRequests + 1;
	
	DLog(@"Lyric request finished: %i of %i [%.2f%%] done",progressFinished,progressTotal,100*((double)progressFinished)/progressTotal);
	[delegate performSelector:@selector(lyricRequestFinished)];
}

@end