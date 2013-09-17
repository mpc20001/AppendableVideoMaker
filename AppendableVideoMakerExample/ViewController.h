//
//  ViewController.h
//  AppendableVideoMakerExample
//
//  Created by Aleks Beer on 20/05/13.
//  Copyright (c) 2013 Aleks Beer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppendableVideoMaker.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface ViewController : UIViewController
{
    AppendableVideoMaker *videoMaker;
    MPMoviePlayerController *player;
    BOOL mergeCompleteEventReceived;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *createVideoBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playVideoBtn;
@property (weak, nonatomic) IBOutlet UIView *videoView;

- (IBAction)onCreateVideo:(id)sender;
- (IBAction)onPlayVideo:(id)sender;

- (void)videoMergeCompleteHandler:(NSNotification*)notification;

@end