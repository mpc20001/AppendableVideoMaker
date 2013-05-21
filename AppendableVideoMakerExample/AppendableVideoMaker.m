//
//  AppendableVideoMaker.m
//  AppendableVideoMaker
//
//  Created by Aleks Beer on 20/05/13.
//  Copyright (c) 2013 Aleks Beer. All rights reserved.
//

#import "AppendableVideoMaker.h"

@implementation AppendableVideoMaker

- (id)init
{
    if (self = [super init])
    {
        videoURLs = [[NSMutableArray alloc] init];
        videoLength = maxVideoLength = 0.0;
        quality = HIGH_QUALITY;
        recording = videoReady = finishing = NO;
        
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        self.showsCameraControls = NO;
        self.navigationBarHidden = YES;
        self.wantsFullScreenLayout = YES;
        self.delegate = self;
        
        self.toolbarHidden = YES;
        [self.toolbar setBackgroundColor:[UIColor blackColor]];
        [self.toolbar setTranslucent:NO];
        
        overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.height)];
        [overlay setBackgroundColor:[UIColor clearColor]];
        [overlay setAlpha:1.0];
        
        UILongPressGestureRecognizer *singleFingerHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerHold:)];
        [singleFingerHold setMinimumPressDuration:0.0];
        [overlay addGestureRecognizer:singleFingerHold];
        
        [self.view addSubview:overlay];
        
        finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.height - 140, 20, 120, 40)];
        [finishBtn setTitle:@"Finish" forState:UIControlStateNormal];
        [finishBtn setBackgroundColor:[UIColor darkGrayColor]];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [finishBtn addTarget:self action:@selector(onFinish:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:finishBtn];
        [self.view bringSubviewToFront:finishBtn];
    }
    
    return self;
}

- (void)handleSingleFingerHold:(UILongPressGestureRecognizer*)recognizer
{
    if (!finishing)
    {
        // check for maxVideoLength
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            if (maxVideoLength > 0.0)
            {
                if (videoLength < maxVideoLength)
                {
                    [self startVideoCapture];
                    timer = CFAbsoluteTimeGetCurrent();
                    recording = YES;
                }
            }
            else
            {
                [self startVideoCapture];
                timer = CFAbsoluteTimeGetCurrent();
                recording = YES;
            }
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            if (recording)
            {
                [self stopVideoCapture];
                videoLength += CFAbsoluteTimeGetCurrent() - timer;
                NSLog(@"VIDEO LENGTH: %f", videoLength);
            }
            recording = NO;
        }
    }
}

- (IBAction)onFinish:(id)sender
{
    NSLog(@"onFinish");
    if (!finishing && videoLength > 0.0)
    {
        finishing = YES;
        AVMutableComposition *comp = [AVMutableComposition composition];
        AVMutableCompositionTrack *compVideoTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *compAudioTrack = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // Working timer
        CMTime startTime = kCMTimeZero;
        NSError *error = nil;
        for (NSURL *videoURL in videoURLs)
        {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
            
            AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [compVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:videoTrack atTime:startTime error:&error];
            
            if ([[asset tracksWithMediaType:AVMediaTypeAudio] count])
            {
                AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
                [compAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:audioTrack atTime:startTime error:&error];
            }
            
            startTime = CMTimeAdd(startTime, [asset duration]);
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dMMMyy-HHmm"];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingFormat:@"/MERGED_%@.mov", [dateFormat stringFromDate:[NSDate date]]];
        NSLog(@"filePath : %@", filePath);
        outputURL = [NSURL fileURLWithPath:filePath];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:comp presetName:(quality == LOW_QUALITY ? AVAssetExportPresetLowQuality : (quality == MEDIUM_QUALITY ? AVAssetExportPresetMediumQuality : AVAssetExportPresetHighestQuality))];
        [exporter setOutputURL:outputURL];
        [exporter setOutputFileType:AVFileTypeQuickTimeMovie];
        [exporter exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch ([exporter status])
             {
                 case AVAssetExportSessionStatusFailed:
                     NSLog(@"Video export failed: %@", [[exporter error] localizedDescription]);
                     [self cleanUpAndFinish];
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     NSLog(@"Video export cancelled.");
                     [self cleanUpAndFinish];
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                     NSLog(@"Video export complete.");
                     [self cleanUpAndFinish];
                     break;
                     
                 default:
                     break;
             }
         }];
    }
}

- (void)cleanUpAndFinish
{
    videoURLs = nil;
    	
    [self dismissViewControllerAnimated:YES completion:^(void)
    {
        videoReady = YES;
    }];
}

- (void)setMaximumVideoLength:(double)max
{
    maxVideoLength = max > 0.0 ? max : 0.0;
}

- (double)getMaximumVideoLength
{
    return maxVideoLength;
}

- (BOOL)videoIsReady
{
    return videoReady;
}

- (NSURL*)getVideoURL
{
    return outputURL;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [videoURLs addObject:[info objectForKey:UIImagePickerControllerMediaURL]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancel called.");
}

@end