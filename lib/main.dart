import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kDisplayName = 'Shaurya Rane';
const String _pictureAsset = 'assets/images/test.jpg';
const String _audioAsset = 'assets/audio/synth_gt.wav';

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
      final audioData = await rootBundle.load(_audioAsset);
      await wavFile.writeAsBytes(audioData.buffer.asUint8List(), flush: true);

      final players = <List<String>>[
        ['aplay', wavFile.path],
        ['paplay', wavFile.path],
        ['play', wavFile.path],
      ];

      var lastError = 'No audio player command succeeded.';
      for (final player in players) {
        try {
          final process = await Process.run(
            player.first,
            player.sublist(1),
            runInShell: false,
          );
          final stderr = (process.stderr as Object?)?.toString().trim() ?? '';
          final stdout = (process.stdout as Object?)?.toString().trim() ?? '';

          if (process.exitCode == 0) {
            setState(() {
              _soundStatus = 'Sound played using ${player.first}.';
            });
            return;
          }

          lastError = stderr.isNotEmpty
              ? '${player.first} failed: $stderr'
              : '${player.first} failed: ${stdout.isEmpty ? 'exit ${process.exitCode}' : stdout}';
        } catch (error) {
          lastError = '${player.first} unavailable: $error';
        }
      }

      setState(() {
        _soundStatus = lastError;
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
                    child: Image.asset(
                      _pictureAsset,
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
