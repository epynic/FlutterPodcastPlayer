import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../utils/enums.dart';
import '../utils/const.dart';

class AudioProvider extends ChangeNotifier {
  AudioPlayer player; // _player huh ?
  static int _nextMediaId = 0;

  bool _showMiniPlayer = false;
  showMiniPlayer() => _showMiniPlayer;

  setMiniPlayerState(state) {
    _showMiniPlayer = state;
    notifyListeners();
  }

  final playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse(
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head - Scratching Science (30 seconds)",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
        extras: {},
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
        extras: {},
      ),
    ),
    AudioSource.uri(
      Uri.parse("https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "From Cat Rheology To Operatic Incompetence",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
        extras: {},
      ),
    )
  ]);

  AudioProvider() {
    player = AudioPlayer();
  }

  initPlayer() async {
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    try {
      await player.setAudioSource(playlist);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }

  startPlaying({index}) {
    player.seek(Duration(seconds: 0), index: index);
    player.play();
    setMiniPlayerState(true);
  }

  APIRequestStatus _apiPlaylistRequestStatus = APIRequestStatus.loaded;
  get getApiPlaylistRequestStatus => _apiPlaylistRequestStatus;

  List _audioItems = [];
  get audioItems => _audioItems;

  fetchPlaylist() async {
    setApiPlaylistRequestStatus(APIRequestStatus.loading);

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var url = Constants.appPlaylistURL;

    try {
      final res = await dio.get(url);
      if (res.statusCode == 200) {
        // TODO This can be a PODO.
        List raw = res.data;
        raw.forEach(
          (ele) {
            _audioItems.add(
              MediaItem(
                id: ele['audiourl'],
                album: ele['album'],
                title: ele['title'],
                artist: ele['artist'],
                duration: Duration(milliseconds: ele['duration']),
                artUri: Uri.parse(ele['artUri']),
                extras: {
                  'episodeid': ele['extras']['episodeid'],
                  'index': ele['extras']['index']
                },
              ),
            );
          },
        );
        setApiPlaylistRequestStatus(APIRequestStatus.loaded);
      } else
        setApiPlaylistRequestStatus(APIRequestStatus.error);
    } catch (e) {
      setApiPlaylistRequestStatus(APIRequestStatus.error);
    }
  }

  setApiPlaylistRequestStatus(APIRequestStatus status) {
    _apiPlaylistRequestStatus = status;
    notifyListeners();
  }
}
