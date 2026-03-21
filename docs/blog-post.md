# Building My AGL Quiz App with Flutter and Yocto

When I first looked at the AGL quiz task, it sounded simple: make a Flutter app with my name, the AGL version, a picture button, and a sound button. The actual work turned out to be much more interesting than that, because the task was really about fitting an app into an embedded Linux workflow, not just making a screen look right.

## The actual task

The deliverable had two sides:

* a Flutter app that runs on AGL
* a Yocto layer and recipe so the app can be integrated into an AGL image

That second part is what makes this different from normal app development. On a laptop, getting the app to run is usually enough. In AGL, the real target is the image build and the runtime environment.

## What I built

I created a Flutter app that:

* displays my name
* reads `/etc/os-release`
* shows the AGL version on screen
* reveals an image when the user presses the picture button
* plays a bundled audio clip when the user presses the sound button

I also created a custom Yocto layer and a recipe for the app so it can be added into the AGL image flow.

## What was easy

The Flutter UI itself was straightforward. Reading `/etc/os-release` from Dart and showing the values on the screen did not take long. The button logic was also simple once the media assets were bundled into the app correctly.

## What was hard

The difficult part was bring-up on the AGL QEMU target.

I ran into several issues:

* `flutter run` failed because of SSH host-key verification
* the custom device setup copied files into the wrong directory
* `flutter-auto` needed corrected runtime arguments
* the guest image could not find `libflutter_engine.so`
* the guest image also could not find `icudtl.dat`
* one of the first image assets displayed incorrectly in QEMU

Each problem was small on its own, but together they showed what embedded development usually feels like: the UI is only one layer of the system, and most of the debugging is in the edges between tools.

## What I learned

The biggest lesson from this task was the difference between application code and deployment code.

The Flutter code answered the product requirement.  
The Yocto layer answered the integration requirement.  
The manual QEMU bring-up answered the runtime requirement.

Until all three are working together, the task is not really done.

I also learned that debugging on AGL often means tracing through:

* host environment setup
* guest filesystem layout
* runtime loader behavior
* launcher configuration
* device transport like SSH and SCP

That is very different from normal mobile or desktop Flutter development.

## Final result

In the final state, the app launches on AGL QEMU, shows the AGL version, displays the image correctly, and triggers sound playback through the Linux audio path. I also collected a final screenshot and a demo recording for submission.

## Closing note

This task started as a Flutter assignment, but it ended up teaching much more about AGL, Yocto, runtime packaging, and target bring-up. That made it much more useful than just building another sample UI.
