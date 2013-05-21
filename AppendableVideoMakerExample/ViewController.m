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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCreateVideo:(id)sender
{
    videoMaker = [[AppendableVideoMaker alloc] init];
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self presentViewController:videoMaker animated:YES completion:^{}];
    }
    else
    {
        [self presentModalViewController:videoMaker animated:YES];
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
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please record a video first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
