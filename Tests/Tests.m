//
//  Tests.m
//  Tests
//
//  Created by Ishaan Gulrajani on 2/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tests.h"
#import "LyricDownloader.h"
#import "LyricWiki.h"
#import "LyricsDotCom.h"
#import "Bing.h"
#import "HindiLyrix.h"
#import "HeuristicScraper.h"
#import "LyricsMode.h"

#define TEST_ARTIST @"U2"
#define TEST_TITLE @"One"
#define TEST_LYRIC @"getting better"

#define FAKE_ARTIST @"ArtistThatClearlyDoesNotExist"
#define FAKE_TITLE @"TitleThatClearlyDoesNotExist"

#define ASSERT_INCLUDE(haystack, needle) GHAssertTrue([haystack rangeOfString:needle].location != NSNotFound, [NSString stringWithFormat: @"String didn't contain %@!",needle]);
#define ASSERT_NIL(object) GHAssertNil(object, @"Object is not nil!");

#define SEARCHER_TEST(searcher) ASSERT_INCLUDE([searcher searchForTitle:TEST_TITLE artist:TEST_ARTIST], TEST_LYRIC);
#define NEGATIVE_SEARCHER_TEST(searcher) ASSERT_NIL([searcher searchForTitle:FAKE_TITLE artist:FAKE_ARTIST]);

@implementation Tests

-(void)testFindLyrics {    
    LyricDownloader *lyricDownloader = [[LyricDownloader alloc] init];
    lyricDownloader.artist = @"U2";
    lyricDownloader.title = @"One";
    
    ASSERT_INCLUDE([lyricDownloader findLyrics], @"getting better");
}

-(void)testLyricWiki {
    SEARCHER_TEST(LyricWiki);
    NEGATIVE_SEARCHER_TEST(LyricWiki);
}

-(void)testLyricsDotCom {
    SEARCHER_TEST(LyricsDotCom);
    NEGATIVE_SEARCHER_TEST(LyricsDotCom);
}

-(void)testBing {
    SEARCHER_TEST(Bing);
    NEGATIVE_SEARCHER_TEST(Bing);
}

-(void)testHindiLyrix {
    NSString *urlString = @"http://www.hindilyrix.com/songs/get_song_Wheres%20The%20Party%20Tonight.html";
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASSERT_INCLUDE([HindiLyrix scrapeURL:url], @"naach all night");
}

-(void)testHeuristicScraper {
    NSString *urlString = @"http://www.lyrics007.com/U2%20Lyrics/One%20Lyrics.html";    
    ASSERT_INCLUDE([HeuristicScraper scrapeURL:[NSURL URLWithString:urlString]], @"getting better");

    urlString = @"http://www.lyrics007.com/NonexistentArtist%20Lyrics/TerribleSong%20Lyrics.html";    
    ASSERT_NIL([HeuristicScraper scrapeURL:[NSURL URLWithString:urlString]]);
}

-(void)testLyricsMode {
    NSString *urlString = @"http://www.lyricsmode.com/lyrics/u/u2/one.html";
    ASSERT_INCLUDE([LyricsMode scrapeURL:[NSURL URLWithString:urlString]], @"getting better");

    urlString = @"http://www.lyricsmode.com/lyrics/n/nonexistentartist/terriblesong.html";
    ASSERT_NIL([LyricsMode scrapeURL:[NSURL URLWithString:urlString]]);
}

@end
