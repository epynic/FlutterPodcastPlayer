import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// ref
// https://github.com/ryanheise/audio_service/tree/one-isolate/audio_service

AudioHandler _audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioSession.instance.then((session) {
    session.configure(AudioSessionConfiguration.speech());
  });

  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelName: 'My Audio App',
      androidEnableQueue: true,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Podcast Player',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: PlayerMain(),
        ));
  }
}

class PlayerMain extends StatefulWidget {
  PlayerMain();

  @override
  _PlayerMainState createState() => _PlayerMainState();
}

class _PlayerMainState extends State<PlayerMain> {
  bool isPlayerReady = false; // just for example
  bool isPlayerPlaying =
      false; // we can also use the AudioProcessing states here
  int playIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initStreams();
  }

  _initStreams() {
    _audioHandler.playbackState.listen((state) {
      playIndex = state.queueIndex;
      // state.processingState  =  AudioProcessingState.ready /AudioProcessingState.loading
      // TODO other states if required we can use
      isPlayerPlaying = state.playing;
      if (state.processingState == AudioProcessingState.ready)
        isPlayerReady = true;
      else
        isPlayerReady = false;

      setState(() {});
      print('playbackState changed: $state');
    });

    _audioHandler.queue.listen((queue) {
      print('queue changed: $queue');
    });

    _audioHandler.queueTitle.listen((queueTitle) {
      print('queueTitle changed: $queueTitle');
    });

    _audioHandler.mediaItem.listen((mediaItem) {
      print('mediaItem changed: $mediaItem');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Column(children: [
        // A seek bar.
        StreamBuilder<Duration>(
          stream: AudioService.getPositionStream(),
          builder: (context, snapshot) {
            final position = snapshot.data;
            return SeekBar(
              duration: MediaLibrary().items[playIndex].duration,
              position: position ?? Duration.zero,
              onChangeEnd: (newPosition) {
                _audioHandler.seek(newPosition);
              },
            );
          },
        ),
        playButton(),
      ]),
    );
  }

  playButton() {
    Widget childButton;

    if (isPlayerReady) {
      childButton = IconButton(
        icon: Icon(isPlayerPlaying ? Icons.pause : Icons.play_arrow),
        iconSize: 50.0,
        onPressed: isPlayerPlaying ? _audioHandler.pause : _audioHandler.play,
      );
    } else {
      childButton = IconButton(
        icon: CircularProgressIndicator(),
        iconSize: 50.0,
        onPressed: null,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.lightGreenAccent,
      ),
      child: childButton,
    );
  }
}

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _mediaLibrary = MediaLibrary();

  AudioPlayerHandler() {
    _init();
  }

  _init() async {
    // Load and broadcast the queue
    queue.add(_mediaLibrary.items);

    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) mediaItem.add(queue.value[index]);
    });

    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen(_broadcastState);

    // In this example, the service stops when reaching the end.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) stop();
    });

    try {
      //await Future.delayed(Duration(seconds: 2)); // magic delay
      await _player.setAudioSource(ConcatenatingAudioSource(
        children: queue.value
            .map((item) => AudioSource.uri(Uri.parse(item.id)))
            .toList(),
      ));

      _player.play();
    } catch (e) {
      // TODO ERROR Handling
      print("Error: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState],
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }
}

// Seekbar

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: (value) {
            if (!_dragging) {
              _dragging = true;
            }
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));
            }
            _dragging = false;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

/// Seekbar

/// Provides access to a library of media items. In your app, this could come
/// from a database or web service.
class MediaLibrary {
  final List<MediaItem> items = [
    MediaItem(
      id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 5739820),
      artUri: Uri.parse(
          'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
      extras: {
        'episodeid': 'episode 1',
        'index': 1,
      },
    ),
    MediaItem(
      id: 'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
      album: "Science Friday",
      title: "From Cat Rheology To Operatic Incompetence",
      artist: "Science Friday and WNYC Studios",
      duration: const Duration(milliseconds: 2856950),
      artUri: Uri.parse(
          'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
      extras: {
        'episodeid': 'episode 2',
        'index': 2,
      },
    ),
  ];
}
