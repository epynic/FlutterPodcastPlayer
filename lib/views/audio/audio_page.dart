import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/theme_config.dart';

// ref
// https://github.com/ryanheise/audio_service/tree/one-isolate/audio_service
AudioHandler _audioHandler;

class AudioPage extends StatefulWidget {
  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage>
    with SingleTickerProviderStateMixin {
  bool showLyrics = false;

  Cubic animationCurve = Curves.fastLinearToSlowEaseIn;
  Duration animationTime = Duration(seconds: 1);

  AnimationController showAnimateController;
  @override
  void initState() {
    super.initState();
    showAnimateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    initAudio();
  }

  initAudio() async {
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

    _initStreams();
  }

  _initStreams() {
    _audioHandler.playbackState.listen((state) {
      //playIndex = state.queueIndex;
      // state.processingState  =  AudioProcessingState.ready /AudioProcessingState.loading
      // TODO other states if required we can use
      //isPlayerPlaying = state.playing;
      // if (state.processingState == AudioProcessingState.ready)
      //   isPlayerReady = true;
      // else
      //   isPlayerReady = false;

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
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.bookmark_border),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: double.infinity),
          AnimatedContainer(
            duration: animationTime,
            curve: animationCurve,
            margin: EdgeInsets.only(bottom: 50),
            height: showLyrics ? 200 : 300,
            child: Image.network(
                'https://img1.od-cdn.com/ImageType-100/0211-1/%7B9C6C5E2A-A7CE-45C8-B940-04032771C3F5%7DImg100.jpg'),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                width: 2,
                color: ThemeConfig.buttonBG,
              ),
            ),
            child: Icon(
              Icons.play_arrow,
              color: ThemeConfig.buttonBG,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: AnimatedContainer(
              duration: animationTime,
              child: showLyrics ? Text('Lyrics Window') : Container(),
            ),
          ),
          AnimatedContainer(
            duration: animationTime,
            curve: animationCurve,
            margin: EdgeInsets.only(bottom: showLyrics ? 20 : 40),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showLyrics = !showLyrics;
                });
                if (showLyrics)
                  showAnimateController.forward();
                else
                  showAnimateController.reverse();
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: showAnimateController,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AudioPlayerHandler() {
    _init();
  }

  final playlist = MediaLibrary();
  final _player = AudioPlayer();

  _init() async {
    // Load and broadcast the queue
    queue.add(playlist.items);

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
