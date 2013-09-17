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
    
    NSCondition *videoURLsCondition;
    BOOL videoURLsLocked;
    
    // Video stuff
    AVMutableComposition *composition;
    AVMutableCompositionTrack *compVideoTrack;
    AVMutableCompositionTrack *compAudioTrack;
    CMTime startTime;
}

- (void)setMaximumVideoLength:(double)max;
- (double)getMaximumVideoLength;

- (void)setQuality:(ExportQuality)vidQuality;
- (ExportQuality)getQuality;

- (void)performAvailableMerges;

- (void)triggerVideoMergeComplete;
- (void)triggerVideoMergeFailed;
- (BOOL)videoIsReady;
- (NSURL*)getVideoURL;

@end
