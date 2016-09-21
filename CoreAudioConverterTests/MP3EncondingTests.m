//
//  MP3EncondingTests.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 28.03.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

@import AVFoundation;

#import <XCTest/XCTest.h>
#import <CoreAudioConverter/CoreAudioConverter.h>

#define TEST_AUDIO NO

@interface MP3EncondingTests : XCTestCase <MP3EncoderDelegate>

@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong) NSArray *workload;
@property (nonatomic, readwrite) CONSTANT_BITRATE bitrate;
@property (nonatomic, readwrite) LAME_QUALITY quality;
@property (nonatomic, readwrite) BOOL cancel;

@end

@implementation MP3EncondingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.opQueue = [[NSOperationQueue alloc] init];
    [self.opQueue setMaxConcurrentOperationCount:[[NSProcessInfo processInfo] processorCount]];
    [self.opQueue setQualityOfService:NSQualityOfServiceUserInitiated];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSFileManager *manager = [NSFileManager defaultManager];
    
    for (EncoderTask *task in self.workload) {
     
        if ([manager fileExistsAtPath:[task.tempURL path]]) {

            [manager removeItemAtURL:task.tempURL error:nil];
        }
    }
    
    self.opQueue = nil;
    self.bitrate = 0;
    self.workload = nil;
    
    [super tearDown];
}

- (void)testMP3Encoding {
    
    _cancel = NO;
    
    // prepare ressources
    NSBundle *bundle = [NSBundle bundleForClass:[MP3EncondingTests class]];
    NSString * kfile1Path = [bundle pathForResource:@"Apple Lossless" ofType:@"m4a"];
    NSString * kfile2Path = [bundle pathForResource:@"Apple MPEG-4-Audio (AAC)" ofType:@"m4a"];
    NSString * kfile3Path = [bundle pathForResource:@"AIFF 44100 Hz Stereo 16 Bit" ofType:@"aif"];
    NSString * kfile4Path = [bundle pathForResource:@"AIFF (Linear PCM 24 Bit Big Endian Ganzzahl mit Vorzeichen)" ofType:@"aiff"];
    NSString * kfile5Path = [bundle pathForResource:@"AIFF (Linear PCM 16 Bit Big Endian Ganzzahl mit Vorzeichen)" ofType:@"aiff"];
    NSString * kfile6Path = [bundle pathForResource:@"AIFF (Linear PCM 8 Bit Ganzzahl mit Vorzeichen)" ofType:@"aiff"];
    NSString * kfile7Path = [bundle pathForResource:@"AAC 44.100 Hz Stereo 320 kbits:s" ofType:@"m4a"];
    NSString * kfile8Path = [bundle pathForResource:@"AAC 44.100 Hz Stereo 80 kbits:s (HE)" ofType:@"m4a"];
    NSString * kfile9Path = [bundle pathForResource:@"WAV Microsoft (Signed 16 bit PCM)" ofType:@"wav"];
    
    NSString * kfile10Path = [bundle pathForResource:@"wrong_filetype" ofType:@"wma"];
    NSString * kfile11Path = [bundle pathForResource:@"wrong_data" ofType:@"m4a"];
    
    
    NSArray *pathArray = @[
                           kfile1Path,
                           kfile2Path,
                           kfile3Path,
                           kfile4Path,
                           kfile5Path,
                           kfile6Path,
                           kfile7Path,
                           kfile8Path,
                           kfile9Path,
                           kfile10Path,
                           kfile11Path
                           ];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSMutableArray *muteArray = [NSMutableArray array];
    
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    NSError *tempDirError = nil;
    BOOL createdTempDir = [manager createDirectoryAtPath:directoryURL.path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&tempDirError];
    if (!createdTempDir) {
        if (tempDirError) NSLog(@"%@", tempDirError);
    }
    
    for (int i = 0 ; i < pathArray.count ; i++) {
        
    
        NSURL *tempFileUrl = [directoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"test-file-out-%d.mp3", i]];
    
        EncoderTask *task = [EncoderTask taskWithInputURL:[NSURL fileURLWithPath:pathArray[i]]
                                                outputURL:tempFileUrl
                                             temporaryURL:tempFileUrl];
        
        [muteArray addObject:task];
    }
    
    NSArray *settingsArray = @[
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_VERY_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_VERY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_VERY_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_VERY_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_GOOD]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_VERY_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_LOW]},
                               
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_VERY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_GOOD]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_HIGH], @"quality": [NSNumber numberWithInt:LAME_QUALITY_LOW]},

                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_GOOD], @"quality": [NSNumber numberWithInt:LAME_QUALITY_VERY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_GOOD], @"quality": [NSNumber numberWithInt:LAME_QUALITY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_GOOD], @"quality": [NSNumber numberWithInt:LAME_QUALITY_GOOD]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_GOOD], @"quality": [NSNumber numberWithInt:LAME_QUALITY_LOW]},
  
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_LOW], @"quality": [NSNumber numberWithInt:LAME_QUALITY_VERY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_LOW], @"quality": [NSNumber numberWithInt:LAME_QUALITY_HIGH]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_LOW], @"quality": [NSNumber numberWithInt:LAME_QUALITY_GOOD]},
                               @{@"bitrate":[NSNumber numberWithInt:CONSTANT_BITRATE_LOW], @"quality": [NSNumber numberWithInt:LAME_QUALITY_LOW]}
                               ];
    for (NSDictionary *settingsDict in settingsArray) {
        
        self.bitrate = [(NSNumber *)[settingsDict valueForKey:@"bitrate"] intValue];
        self.quality = [(NSNumber *)[settingsDict valueForKey:@"quality"] intValue];
        self.workload = [muteArray copy];
        
        for (EncoderTask *task in self.workload) {
            
            MP3Encoder *mp3Encoder = [[MP3Encoder alloc] initWithDelegate:self];
            
            NSError *encError = nil;
            BOOL erfolg = [mp3Encoder executeTask:task
                                            error:&encError];
            if (!erfolg) {
                if (encError) NSLog(@"%@", encError);
                else NSLog(@"Encoding of file \"%@\"failed without error.", task.inputURL.lastPathComponent);
            }
        }

        if (TEST_AUDIO) {
            for (EncoderTask *task in self.workload) {
                
                NSURL* file = task.tempURL;
                
                if ([manager fileExistsAtPath:file.path]) {
                    
                    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
                    [audioPlayer prepareToPlay];
                    [audioPlayer play];
                    sleep(4);
                    [audioPlayer pause];
                }
            }
        }
        
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[0] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[1] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[2] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[3] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[4] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[5] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[6] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[7] tempURL].path], @"Converting Failed");
        XCTAssertTrue([manager fileExistsAtPath:[self.workload[8] tempURL].path], @"Converting Failed");
        XCTAssertTrue(![manager fileExistsAtPath:[self.workload[9] tempURL].path], @"Converting Failed");
        XCTAssertTrue(![manager fileExistsAtPath:[self.workload[10] tempURL].path], @"Converting Failed");
    }
    
}

#pragma mark Delegate Methodes

- (void)encodingFinished:(NSDictionary *)dict {
    
    NSLog(@"%@", dict);
}
- (void)encodingFinishedwithErrors:(NSArray *)errorArray {
    
    if (errorArray.count > 0) NSLog(@"%@", errorArray);
}

#pragma mark -
@end
