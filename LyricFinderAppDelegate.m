//
//  LyricalAppDelegate.m
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricFinderAppDelegate.h"
#import "Controller.h"
#import "NSString+LyricFinder.h"
#import "ASIHTTPRequest.h"

@interface LyricFinderAppDelegate ()
-(void)updateProgressMessage;
@end


@implementation LyricFinderAppDelegate
@synthesize window, controller, progressIndicator, progressMessage, infoMessage, button, lowerInfoMessage, ratingRequest, ratingButton;

-(void)dealloc {
	[controller release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[window center];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSURL *url = [NSURL URLWithString:@"http://lyricfinderapp.com/status.html"];
        NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        contents = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        DLog(@"contents: '%@'",contents);
        if(![contents isEqualToString:@"OK"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSWorkspace sharedWorkspace] openURL:url];
            });
        }
    });
}

-(IBAction)buttonPressed:(id)sender {
	[progressIndicator startAnimation:self];
	[progressMessage setStringValue:@"Scanning library for songs without lyrics..."];
	
	[button setHidden:YES];
	[infoMessage setHidden:YES];
	[progressIndicator setHidden:NO];
	[progressMessage setHidden:NO];
	
	controller = [[Controller alloc] init];
	controller.delegate = self;
    
	[controller beginWorking];
}

-(void)libraryScanFinished {
	[progressIndicator setIndeterminate:NO];
	[progressIndicator setMaxValue:1.0];
	[self updateProgressMessage];
}

-(void)lyricRequestFinished {
	[progressIndicator setDoubleValue:((double)controller.progressFinished / controller.progressTotal)];
	[self updateProgressMessage];
}

-(void)updateProgressMessage {
	[progressMessage setStringValue:[NSString stringWithFormat:@"Finding and adding lyrics... finished %i of %i",controller.progressFinished,controller.progressTotal]];
	if(controller.progressFinished == controller.progressTotal) {
		[progressMessage setHidden:YES];
		[progressIndicator setHidden:YES];
		
		[infoMessage setStringValue:@"Done!"];
		[infoMessage setFont:[NSFont boldSystemFontOfSize:13.0]];
		[infoMessage setHidden:NO];

		int success = controller.totalSuccesses;
		int total = controller.totalSongs;
		[lowerInfoMessage setStringValue:[NSString stringWithFormat:@"Found lyrics for %i of %i songs (%.0f%%).",success,total,((double)success*100)/(total==0 ? 1 : total)]];
		[lowerInfoMessage setHidden:NO];
        
        [ratingRequest setHidden:NO];
        [ratingButton setHidden:NO];
	}
}

- (IBAction)ratingButtonPressed:(id)sender {
    NSString *urlString = @"macappstore://itunes.apple.com/us/app/lyric-finder/id415321782?mt=12";
    
    // Mac App Store URLs need to be opened twice, once and then again four seconds later (Apple's site uses two seconds, but it didn't always work for me). 
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(4);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];     
        });
    });
}

@end