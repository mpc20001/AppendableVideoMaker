## Summary


AppendableVideoMaker is a custom UIImagePickerController which offers Vine-like tap-and-hold stop-start video recording functionality.</p>


## How to use it

<ol>
<li>Drag and drop `AppendableVideoMaker.m` and `AppendableVideoMaker.h` into your project</li>
<li>Add the import statement:</li>
</ol>
```
#import "AppendableVideoMaker.h"
```
<ol start="3">
<li>Initialize AppendableVideoMaker and check if the device can record videos. If so, setup success/fail observers, then display the recorder:</li>
</ol>
```
AppendableVideoMaker videoMaker = [[AppendableVideoMaker alloc] init];
if ([videoMaker deviceCanRecordVideos])
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoMergeCompleteHandler:)
                                           		 name:@"AppendableVideoMaker_VideoMergeComplete"
                                           	   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoMergeFailedHandler:)
                                           		 name:@"AppendableVideoMaker_VideoMergeFailed"
                                           	   object:nil];
	[self presentViewController:videoMaker animated:YES completion:^{}];
}
```
<ol start="4">
<li>Videos are saved to the Documents directory. When you have finished creating a video, check if the video is ready and get the URL path to it.</li>
</ol>
```
if ([videoMaker videoIsReady])
{
	NSURL *videoURL = [videoMaker getVideoURL];
	// do something with the video ...
}
```


## Features

<ul>
<li>Tap and hold video recording</li>
<li>Video merging</li>
</ul>


## To do

<ul>
<li>Merge already recorded videos in background whilst recording others</li>
<li>Create a callback for when video is ready or fails to merge properly</li>
<li>Display a label to show current length of video</li>
<li>Add the ability to set a maximum video length</li>
<li>Display progress bar for maximum video length</li>
<li>Add a button to restart video from scratch</li>
<li>Tidy up interface to look nicer</li>
</ul>


## Contributors

<a href="https://twitter.com/AleksBeer" target="_blank">Aleks Beer</a>

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/20474c2d20c32691c345993857c97b9c "githalytics.com")](http://githalytics.com/AleksBeer/AppendableVideoMaker)