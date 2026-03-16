# AGL Quiz Flutter App

Minimal Flutter app for the AGL quiz task.

## Features

* Displays the AGL version by reading `/etc/os-release`
* Displays the developer name
* Shows a picture when the picture button is pressed
* Plays a bundled WAV tone through `aplay` when the sound button is pressed

## Local workspace flow

Use the meta-flutter workspace automation:

```bash
cd /home/sra-vjti/workspace-automation-main
./flutter_workspace.py --enable agl-qemu-master
source /home/sra-vjti/workspace-automation-main/setup_env.sh
cd /home/sra-vjti/agl-quiz-flutter-app
flutter run -d agl-qemu-master
```

## Notes

* No third-party Dart packages are required for the app logic.
* The app currently uses `aplay`, so the target image must contain `alsa-utils-aplay` or an equivalent provider.

