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
@synthesize totalSongs, progressFinished,progressTotal,successfulRequests,totalSuccesses,delegate;

-(void)dealloc {
	[lyricRequests release];
	[super dealloc];
}

-(void)beginWorking {

    DLog(@"Beginning process...");
	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	DLog(@"iTunesApplication *iTunes = %@",iTunes);
    [iTunes run];
    DLog(@"[iTunes run] just called; [iTunes isRunning]==%i",[iTunes isRunning]);
    
	// find the library
    DLog(@"Looking for iTunes sources:");
    iTunesSource *librarySource = nil;
	for(iTunesSource *source in [iTunes sources]) {
        
        NSString *sourceKind = @"undefined";
        switch([source kind]) {
            case iTunesESrcLibrary: sourceKind = @"kLib"; break;
            case iTunesESrcIPod: sourceKind = @"kPod"; break;
            case iTunesESrcAudioCD: sourceKind = @"kACD"; break;
            case iTunesESrcMP3CD: sourceKind = @"kMCD"; break;
            case iTunesESrcDevice: sourceKind = @"kDev"; break;
            case iTunesESrcRadioTuner: sourceKind = @"kTun"; break;
            case iTunesESrcSharedLibrary: sourceKind = @"kShd"; break;
            case iTunesESrcUnknown: sourceKind = @"kUnk"; break;
        }
        
        DLog(@"Found source: [source kind]==%@",sourceKind);
        
        if([source kind] == iTunesESrcLibrary) {
            DLog(@"[source kind]==iTunesESrcLibrary; using this source.");
			librarySource = source;
			break;
		}
	}
	
	// find the main playlist
	DLog(@"Looking for the main playlist...");
    iTunesPlaylist *musicPlaylist = nil;
	for(iTunesPlaylist *playlist in [librarySource playlists]) {
		DLog(@"Found playlist: [playlist name]==%@",[playlist name]);
        
        if([[playlist name] isEqualToString:@"Music"]) {
            DLog(@"[playlist name]==Music; using this playlist.");
			musicPlaylist = playlist;
		}
	}

	lyricRequests = [[NSMutableArray alloc] initWithCapacity:1000];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DLog(@"dispatch_async block started, selecting tracks...");
        
		for(iTunesTrack *track in [musicPlaylist tracks]) {            
			totalSongs++;
            
            int lyricsLength = [[track lyrics] length];
			BOOL oldLyrics = lyricsLength > 9;
			
            DLog(@"Evaluating track: [[track lyrics] length]==%i",lyricsLength);
            
			if(!oldLyrics) {
				LyricRequest *request = [[LyricRequest alloc] initWithTrack:track];
				[lyricRequests addObject:request];
				[request release];
				DLog(@"Queued {%@,%@}",[track artist],[track name]);
			} else {
                totalSuccesses++;
				DLog(@"Didn't queue {%@,%@}",[track artist],[track name]);
			}
		}
		
		DLog(@"Finished queueing tracks: %i tracks in queue",lyricRequests.count);
		
		dispatch_async(dispatch_get_main_queue(), ^{
            DLog(@"dispatch_async(main queue) started, starting library scan...");
			self.progressTotal = lyricRequests.count;
			[delegate performSelector:@selector(libraryScanFinished)];
			[self fullfillAndApplyLyricRequests];
		});
	});

}

-(void)fullfillAndApplyLyricRequests {
    DLog(@"Stage 2 started, beginning async dispatch...");
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		DLog(@"Stage 2 async started...");
        
        for(LyricRequest *request in lyricRequests) {
            DLog(@"Evaluating lyric request... ");
            
            [request fulfill];
			
			dispatch_sync(dispatch_get_main_queue(), ^{
				BOOL result = YES;[request apply];
				[self lyricRequestFinishedSuccessfully:result];
			});
		}
	});	
}

-(void)lyricRequestFinishedSuccessfully:(BOOL)success {
	self.progressFinished = self.progressFinished + 1;
	if(success) {
		totalSuccesses++;
        successfulRequests++;
	}
	DLog(@"Lyric request finished (successfully? %@): %i of %i [%.2f%%] done",(success ? @"YES" : @"NO"),progressFinished,progressTotal,100*((double)progressFinished)/progressTotal);
	[delegate performSelector:@selector(lyricRequestFinished)];
}

@end