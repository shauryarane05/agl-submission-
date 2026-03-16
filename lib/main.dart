import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

const String kDisplayName = 'Shaurya Rane';

const String _pictureBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAAdUlEQVR4nO3PQQ3AIADAQEA50jHB'
    'vwyJgn2tgm3vs8eJv+0A3zWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oD'
    'WgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgfQDbvwF/x9VorgAAAABJRU5ErkJggg==';

const String _wavBase64 =
    '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';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGL Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF76B82A)),
        useMaterial3: true,
      ),
      home: const QuizHomePage(),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  String _aglVersion = 'Loading /etc/os-release...';
  bool _showPicture = false;
  String? _soundStatus;
  bool _isPlayingSound = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAglVersion());
  }

  Future<void> _loadAglVersion() async {
    try {
      final releaseFile = File('/etc/os-release');
      if (!await releaseFile.exists()) {
        setState(() {
          _aglVersion = '/etc/os-release not found';
        });
        return;
      }

      final lines = await releaseFile.readAsLines();
      final values = <String, String>{};
      for (final line in lines) {
        if (!line.contains('=')) {
          continue;
        }
        final separator = line.indexOf('=');
        final key = line.substring(0, separator);
        final value = line.substring(separator + 1).replaceAll('"', '');
        values[key] = value;
      }

      final prettyName = values['PRETTY_NAME'];
      final version = values['VERSION'];
      final versionId = values['VERSION_ID'];
      final display = [
        if (prettyName != null && prettyName.isNotEmpty) prettyName,
        if (version != null && version.isNotEmpty && version != prettyName) version,
        if (versionId != null && versionId.isNotEmpty) 'VERSION_ID=$versionId',
      ].join(' | ');

      setState(() {
        _aglVersion = display.isEmpty ? 'AGL version unavailable' : display;
      });
    } catch (error) {
      setState(() {
        _aglVersion = 'Failed to read /etc/os-release: $error';
      });
    }
  }

  Future<void> _playSound() async {
    setState(() {
      _isPlayingSound = true;
      _soundStatus = 'Playing sound...';
    });

    final tempDir = await Directory.systemTemp.createTemp('agl_quiz_sound_');
    final wavFile = File('${tempDir.path}/quiz-tone.wav');

    try {
      await wavFile.writeAsBytes(base64Decode(_wavBase64), flush: true);

      final process = await Process.run(
        'aplay',
        [wavFile.path],
        runInShell: false,
      );

      final stderr = (process.stderr as Object?)?.toString().trim() ?? '';
      final stdout = (process.stdout as Object?)?.toString().trim() ?? '';

      setState(() {
        if (process.exitCode == 0) {
          _soundStatus = 'Sound played successfully.';
        } else {
          _soundStatus = stderr.isNotEmpty
              ? 'aplay failed: $stderr'
              : 'aplay failed: ${stdout.isEmpty ? 'exit ${process.exitCode}' : stdout}';
        }
      });
    } catch (error) {
      setState(() {
        _soundStatus = 'Unable to play sound: $error';
      });
    } finally {
      setState(() {
        _isPlayingSound = false;
      });
      unawaited(tempDir.delete(recursive: true).catchError((_) {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pictureBytes = base64Decode(_pictureBase64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AGL Quiz App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  kDisplayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'AGL Version',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _aglVersion,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        setState(() {
                          _showPicture = !_showPicture;
                        });
                      },
                      icon: const Icon(Icons.image),
                      label: Text(_showPicture ? 'Hide Picture' : 'Show Picture'),
                    ),
                    FilledButton.icon(
                      onPressed: _isPlayingSound ? null : _playSound,
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Play Sound'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _showPicture
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(height: 220),
                  secondChild: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      pictureBytes,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _soundStatus ?? 'Press the sound button to play the bundled WAV tone.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

