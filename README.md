<!DOCTYPE html>
<html>
<body>              
  <div id="readme" class="blob instapaper_body">
    <article class="markdown-body entry-content" itemprop="mainContentOfPage">
      <h2><a name="summary" class="anchor" href="#summary"><span class="octicon octicon-link"></span></a>Summary</h2>

      <p>AppendableVideoMaker is a custom UIImagePickerController which offers Vine-like stop-start video recording functionality.</p>

      <h2>
      <a name="how-to-use-it" class="anchor" href="#how-to-use-it"><span class="octicon octicon-link"></span></a>How to use it</h2>

      <ol>
      <li>Drag and drop <strong>AppendableVideoMaker.m</strong> and <strong>AppendableVideoMaker.h</strong> into your project</li>
      <li>Add the import statement:</li>
      </ol><pre><code>#import "AppendableVideoMaker.h"
      </code></pre>

      <ol start="3">
      <li>Create and display an AppendableVideoMaker:</li>
      </ol><pre><code>AppendableVideoMaker videoMaker = [[AppendableVideoMaker alloc] init];
      [self presentViewController:videoMaker animated:YES completion:^{}];
      </code></pre>

      <ol start="4">
      <li>Videos are saved to the Documents directory. When you have finished creating a video, check if the video is ready and get the URL path to it.</li>
      </ol><pre><code>if ([videoMaker videoIsReady])
      {
      NSURL *videoURL = [videoMaker getVideoURL];
      ...
      }
      </code></pre>

      <h2>
      <a name="features" class="anchor" href="#features"><span class="octicon octicon-link"></span></a>Features</h2>

      <ul>
      <li>Tap and hold video recording</li>
      <li>Video merging</li>
      </ul><h2>
      <a name="to-do" class="anchor" href="#to-do"><span class="octicon octicon-link"></span></a>To do</h2>

      <ul>
      <li>Merge already recorded videos in background whilst recording others</li>
      <li>Create a callback for when video is ready or fails to merge properly</li>
      <li>Display a label to show current length of video</li>
      <li>Add the ability to set a maximum video length</li>
      <li>Display progress bar for maximum video length</li>
      <li>Add a button to restart video from scratch</li>
      <li>Tidy up interface to look nicer</li>
      </ul><h2>
      <a name="contributors" class="anchor" href="#contributors"><span class="octicon octicon-link"></span></a>Contributors</h2>

      <p><a href="http://a.leks.be/er" target="_blank">Aleks Beer</a></p
    </article>
  </div>
</body>
</html>