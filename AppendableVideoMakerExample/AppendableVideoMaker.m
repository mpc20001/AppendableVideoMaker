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
        [self checkForVideoSupport];
        
        // Only set everything up if the device can record videos
        
        if (deviceSupportsVideoRecording)
        {
            // Setup the variables
            
            videoURLs = [[NSMutableArray alloc] init];
            videoLength = maxVideoLength = 0.0;
            quality = HIGH_QUALITY;
            recording = videoReady = finishing = NO;
            videoURLsCondition = [[NSCondition alloc] init];
            videoURLsLocked = NO;
            
            // Setup the actual camera controller itself, hiding all normal components
            
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
            self.showsCameraControls = NO;
            self.navigationBarHidden = YES;
            self.wantsFullScreenLayout = YES;
            self.delegate = self;
            self.toolbarHidden = YES;
            
            // Setup the transparent overlay for tap and hold capabilities
            
            overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.height)];
            [overlay setBackgroundColor:[UIColor clearColor]];
            [overlay setAlpha:1.0];
            
            // Setup the tap and hold recognizer for the transparent overlay
            
            UILongPressGestureRecognizer *singleFingerHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerHold:)];
            [singleFingerHold setMinimumPressDuration:0.0];
            [overlay addGestureRecognizer:singleFingerHold];
            [self.view addSubview:overlay];
            
            // Setup the finish button
            
            UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIApplication sharedApplication].statusBarFrame.size.width, 44)];
            [toolBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
            [self.view addSubview:toolBar];
            [self.view bringSubviewToFront:toolBar];
            
            UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc] initWithTitle:@"Finish"
                                                                          style:UIBarButtonItemStyleDone
                                                                         target:self
                                                                         action:@selector(onFinish:)];
            UIBarButtonItem *restartBtn = [[UIBarButtonItem alloc] initWithTitle:@"Restart"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(onRestart:)];
            UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:self
                                                                                       action:nil];
            [toolBar setItems:[NSMutableArray arrayWithObjects:flexSpace, restartBtn, finishBtn, nil]];
            
            // Setup video stuff
            
            composition = [AVMutableComposition composition];
            compVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                      preferredTrackID:kCMPersistentTrackID_Invalid];
            compAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                      preferredTrackID:kCMPersistentTrackID_Invalid];
            startTime = kCMTimeZero;
        }
    }
    
    return self;
}

#pragma mark - Custom Functions (Alphabetical order)

- (void)checkForAvailableMerges
{
    if (!videoURLsLocked && videoURLs.count > 0 && lastVideoMerged < (videoURLs.count))
    {
        // Extra videos are available for merging
        
        [NSThread detachNewThreadSelector:@selector(performAvailableMerges)
                                 toTarget:self
                               withObject:nil];
    }
}

- (void)checkForVideoSupport
{
    // Check if the device has a camera
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Check if the camera supports video
        
        deviceSupportsVideoRecording = [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:(id)kUTTypeMovie];
    }
    else
    {
        // Device does not have a camera
        
        deviceSupportsVideoRecording = NO;
    }
}

- (void)cleanUpAndFinish
{
    // Clear the videos list from memory
    
    videoURLs = nil;
    lastVideoMerged = 0;
}

- (BOOL)deviceCanRecordVideos
{
    return deviceSupportsVideoRecording;
}

- (void)exportVideo
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dMMMyy-HHmm"];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingFormat:@"/MERGED_%@.mov", [dateFormat stringFromDate:[NSDate date]]];
    
    outputURL = [NSURL fileURLWithPath:filePath];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:(quality == LOW_QUALITY ? AVAssetExportPresetLowQuality : (quality == MEDIUM_QUALITY ? AVAssetExportPresetMediumQuality : AVAssetExportPresetHighestQuality))];
    [exporter setOutputURL:outputURL];
    [exporter setOutputFileType:AVFileTypeQuickTimeMovie];
    [exporter exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch ([exporter status])
         {
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Video (final) export failed: %@", [[exporter error] localizedDescription]);
                 [self performSelectorOnMainThread:@selector(triggerVideoMergeFailed) withObject:nil waitUntilDone:NO];
                 break;
                 
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Video (final) export cancelled.");
                 [self performSelectorOnMainThread:@selector(triggerVideoMergeFailed)
                                        withObject:nil
                                     waitUntilDone:NO];
                 break;
                 
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"Video (final) export complete.");
                 [self performSelectorOnMainThread:@selector(triggerVideoMergeComplete)
                                        withObject:nil
                                     waitUntilDone:NO];
                 break;
                 
             default:
                 break;
         }
     }];
}

- (double)getMaximumVideoLength
{
    return maxVideoLength;
}

- (ExportQuality)getQuality
{
    return quality;
}

- (NSURL*)getVideoURL
{
    return outputURL;
}

- (void)hideController
{
    // Hide the AppendableVideoMaker controller
    
    [self dismissViewControllerAnimated:YES completion:^(void)
     {
     }];
}

- (void)mergeVideo:(NSURL*)videoURL
{
    // Working timer
    NSError *error = nil;
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                            ofTrack:videoTrack
                             atTime:startTime
                              error:&error];
    
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count])
    {
        AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                ofTrack:audioTrack
                                 atTime:startTime
                                  error:&error];
    }
    
    startTime = CMTimeAdd(startTime, [asset duration]);
}

- (void)performAvailableMerges
{
    if (videoURLsLocked)
    {
        // Wait for videoURLs array to unlock
        [videoURLsCondition wait];
    }
    
    [videoURLsCondition lock];
    
    NSMutableArray *videoURLsCopy = [videoURLs copy];
    
    // Working timer
    int i = 0;
    for (NSURL *videoURL in videoURLsCopy)
    {
        if (++i > lastVideoMerged)
        {
            [self mergeVideo:videoURL];
            lastVideoMerged = i;
        }
    }
    
    [videoURLsCondition broadcast];
    [videoURLsCondition unlock];
}

- (void)setMaximumVideoLength:(double)max
{
    maxVideoLength = max > 0.0 ? max : 0.0;
}

- (void)setQuality:(ExportQuality)vidQuality
{
    quality = vidQuality;
}

- (void)triggerVideoMergeComplete
{
    videoReady = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppendableVideoMaker_VideoMergeComplete"
                                                        object:nil];
}

- (void)triggerVideoMergeFailed
{
    videoReady = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppendableVideoMaker_VideoMergeFailed"
                                                        object:nil];
}

- (BOOL)videoIsReady
{
    return videoReady;
}

#pragma mark - Interaction Handlers (Alphabetical order)

- (void)handleSingleFingerHold:(UILongPressGestureRecognizer*)recognizer
{
    if (!finishing)
    {        
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {            
            if (maxVideoLength > 0.0)
            {                
                if (videoLength < maxVideoLength)
                {
                    // Only allow recording if maxVideoLength has not been reached
                    
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
                
                [self checkForAvailableMerges];
            }
            recording = NO;
        }
    }
}

- (IBAction)onFinish:(id)sender
{
    // Check if the finish button hasn't already been pressed and that there is at least one video stored
    [self hideController];
    
    if (!finishing && videoURLs.count >= 1)
    {
        if (videoURLs.count == 1)
        {
            // If there is only one video
            
            outputURL = [videoURLs objectAtIndex:0];
            
            [self cleanUpAndFinish];
        }
        else
        {
            // If there is more than one video
            
            [self performAvailableMerges];
            
            [self exportVideo];
        }
    }
}

- (IBAction)onRestart:(id)sender
{    
    if (!finishing && videoURLs.count >= 1)
    {        
        videoURLs = [[NSMutableArray alloc] init];
        videoLength = maxVideoLength = 0.0;
        
        recording = videoReady = finishing = NO;
        videoURLsCondition = [[NSCondition alloc] init];
        videoURLsLocked = NO;
    }
}

#pragma mark - UIImagePickerControllerDelegate &  UIImagePickerViewDataSource methods methods

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [videoURLs addObject:[info objectForKey:UIImagePickerControllerMediaURL]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancel called.");
}

@end