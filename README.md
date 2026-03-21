# AGL Quiz Flutter App

This repository contains my Flutter submission for the AGL quiz task.

The app was built to run on an Automotive Grade Linux target and does four things:

* shows my name
* reads the AGL version from `/etc/os-release`
* shows a picture when the picture button is pressed
* plays a bundled sound when the sound button is pressed

## Why this app exists

The task was not only to build a Flutter UI. The real requirement was to make a Flutter app that can fit into an AGL workflow, which means:

* building the app
* testing it against an AGL target
* preparing a Yocto recipe so it can be integrated into an AGL image

That is why this repository is paired with a separate Yocto layer repository.

## App behavior

The main implementation is in [lib/main.dart](/home/sra-vjti/agl-quiz-flutter-app/lib/main.dart).

What the app does:

* reads `/etc/os-release` using Dart `File` I/O
* extracts fields such as `PRETTY_NAME`, `VERSION`, and `VERSION_ID`
* displays the parsed version on screen
* loads a bundled image asset
* loads a bundled WAV file and tries playback with Linux audio tools such as `aplay`

## Assets

Bundled assets used by the app:

* [assets/images/test.jpg](/home/sra-vjti/agl-quiz-flutter-app/assets/images/test.jpg)
* [assets/audio/synth_gt.wav](/home/sra-vjti/agl-quiz-flutter-app/assets/audio/synth_gt.wav)

Proof assets from the final AGL run:

* [docs/show-picture.png](/home/sra-vjti/agl-quiz-flutter-app/docs/show-picture.png)
* [docs/final-demo.webm](/home/sra-vjti/agl-quiz-flutter-app/docs/final-demo.webm)

## How I ran it on AGL QEMU

The practical bring-up path that worked for me used the manual workspace here:

* [agl-quiz-manual-workspace](/home/sra-vjti/agl-quiz-manual-workspace)

Start AGL QEMU:

```bash
source /home/sra-vjti/agl-quiz-manual-workspace/setup_env.sh
run-agl-qemu-master
```

Then in another terminal:

```bash
source /home/sra-vjti/agl-quiz-manual-workspace/setup_env.sh
cd /home/sra-vjti/agl-quiz-manual-workspace/app/agl-quiz-flutter-app
flutter run -d agl-qemu-master
```

If the custom device is not detected, the manual target launch path is:

```bash
source /home/sra-vjti/agl-quiz-manual-workspace/setup_env.sh
cd /home/sra-vjti/agl-quiz-manual-workspace/app/agl-quiz-flutter-app
flutter build bundle
ssh -p 2222 agl-driver@localhost 'rm -rf /tmp/agl_quiz_flutter_app && mkdir -p /tmp/agl_quiz_flutter_app/data/flutter_assets'
scp -P 2222 /home/sra-vjti/agl-quiz-manual-workspace/.config/flutter_workspace/agl-qemu-master/default_config.json agl-driver@localhost:/tmp/agl_quiz_flutter_app/
scp -P 2222 -r build/flutter_assets/* agl-driver@localhost:/tmp/agl_quiz_flutter_app/data/flutter_assets/
ssh -t -t -p 2222 agl-driver@localhost 'LD_LIBRARY_PATH=/usr/share/flutter/3.38.3/debug/lib flutter-auto -j /tmp/agl_quiz_flutter_app/default_config.json -b /tmp/agl_quiz_flutter_app'
```

## Bugs and fixes during bring-up

The interesting part of this task was not the UI. The harder part was getting the app to run on the AGL target.

Main issues I hit:

* SSH host-key verification broke non-interactive `flutter run`
* the custom-device install path created the wrong target directory
* `flutter-auto` arguments needed correction
* the target runtime could not find `libflutter_engine.so`
* the target runtime could not find `icudtl.dat`
* the first image asset rendered badly on QEMU, so it was replaced
* the sound path worked through `aplay`, but audio still depended on QEMU host routing

Those issues and fixes are written in more detail in:

* [AGL-TASK.md](/home/sra-vjti/AGL-TASK.md)

## Repository structure

* [lib/main.dart](/home/sra-vjti/agl-quiz-flutter-app/lib/main.dart): app logic
* [pubspec.yaml](/home/sra-vjti/agl-quiz-flutter-app/pubspec.yaml): Flutter configuration and bundled assets
* [docs/show-picture.png](/home/sra-vjti/agl-quiz-flutter-app/docs/show-picture.png): final screenshot
* [docs/final-demo.webm](/home/sra-vjti/agl-quiz-flutter-app/docs/final-demo.webm): final demo recording

## Related repository

The Yocto layer used for image integration lives in:

* [meta-agl-quiz](/home/sra-vjti/meta-agl-quiz)
