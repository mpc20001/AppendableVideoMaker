//
//  ViewController.m
//  AppendableVideoMakerExample
//
//  Created by Aleks Beer on 20/05/13.
//  Copyright (c) 2013 Aleks Beer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self checkForVideoSupport];
    
    mergeCompleteEventReceived = NO;
    self.playVideoBtn.enabled = NO;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

/*
 *
 *  FUNCTIONS
 *
 */

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

/*
 *
 *  INTERACTION HANDLERS
 *
 */

- (IBAction)onCreateVideo:(id)sender
{
    if (deviceSupportsVideoRecording)
    {
        videoMaker = [[AppendableVideoMaker alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoMergeCompleteHandler:)
                                                     name:@"VideoMergeComplete" object:nil];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
        {
            [self presentViewController:videoMaker animated:YES completion:^{}];
        }
        else
        {
            // Deprecated in iOS 6
            
            [self presentModalViewController:videoMaker animated:YES];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"This device is not able to record videos! :("
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)onPlayVideo:(id)sender
{
    if ([videoMaker videoIsReady])
    {
        player = [[MPMoviePlayerController alloc] initWithContentURL:[videoMaker getVideoURL]];
        player.view.frame = self.videoView.bounds;
        player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.videoView addSubview:player.view];
        [player play];
    }
    else if (![videoMaker videoIsReady])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Video has not finished merging! Please be patient.."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"You need to record a video first!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

/*
 *
 *  EVENT HANDLERS
 *
 */

- (void)videoMergeCompleteHandler:(NSNotification*)notification
{
    [self.playVideoBtn setEnabled:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Success"
                                message:@"Your merged video is now ready to watch!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
