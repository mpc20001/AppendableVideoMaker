//
//  AppendableVideoMaker.h
//  AppendableVideoMaker
//
//  Created by Aleks Beer on 20/05/13.
//  Copyright (c) 2013 Aleks Beer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

typedef enum
{
    LOW_QUALITY = 1,
    MEDIUM_QUALITY = 2,
    HIGH_QUALITY = 3
} ExportQuality;

@interface AppendableVideoMaker : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL deviceSupportsVideoRecording;
    
    NSMutableArray *videoURLs;
    NSURL *outputURL;
    
    CFTimeInterval timer;
    BOOL recording;
    BOOL finishing;
    BOOL videoReady;
    double videoLength;
    double maxVideoLength;
    ExportQuality quality;
    int lastVideoMerged;
    
    UIView* overlay;
    NSTimer *blinkTimer;
    NSCondition *videoURLsCondition;
    BOOL videoURLsLocked;
    UILabel * recordLabel;
    // Video stuff
    AVMutableComposition *composition;
    AVMutableCompositionTrack *compVideoTrack;
    AVMutableCompositionTrack *compAudioTrack;
    CMTime startTime;
    UIAlertView * loadingAlert2;
    AVMutableVideoCompositionLayerInstruction *firstlayerInstruction;
    BOOL isFirstAssetPortrait_;
}

- (void)checkForAvailableMerges;
- (void)checkForVideoSupport;
- (void)cleanUpAndFinish;
- (BOOL)deviceCanRecordVideos;
- (double)getMaximumVideoLength;
- (NSURL*)getVideoURL;
- (ExportQuality)getQuality;
- (void)performAvailableMerges;
- (void)setMaximumVideoLength:(double)max;
- (void)setQuality:(ExportQuality)vidQuality;
- (void)triggerVideoMergeComplete;
- (void)triggerVideoMergeFailed;
- (BOOL)videoIsReady;

@end
