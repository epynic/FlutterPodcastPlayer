import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../utils/enums.dart';
import '../utils/const.dart';

class AudioProvider extends ChangeNotifier {
  AudioPlayer player; // _player huh ?
  static int _nextMediaId = 0;
  var playlist;

  bool _showMiniPlayer = false;
  showMiniPlayer() => _showMiniPlayer;

  setMiniPlayerState(state) {
    _showMiniPlayer = state;
    notifyListeners();
  }

  // var playlist = ConcatenatingAudioSource(children: [
  //   AudioSource.uri(
  //     Uri.parse(
  //       "https://drive.google.com/uc?export=download&id=1Ncw7_5F0VTpXVUx0Gy_ttnOINILElFG8",
  //     ),
  //     tag: MediaItem(
  //       id: '${_nextMediaId++}',
  //       album: "Science Friday",
  //       title: "A Salute To Head - Scratching Science (30 seconds)",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //       extras: {
  //         'lyrics':
  //             "[00:00.10]Dua Lipa - Levitating \n[00:09.49]If you wanna run away with me I know a galaxy \n[00:11.71]and I can take you for a ride \n[00:13.99]I had a premonition that we fell into a rhythm \n[00:16.32]Where the music don't stop for life \n[00:18.74]Glitter in the sky glitter in my eyes \n[00:21.08]Shining just the way I like \n[00:23.40]If you feelin like you need a little bit of company \n[00:25.83]You met me at the perfect time \n[00:28.55]You want me I want you baby \n[00:30.74]My sugarboo I'm levitating \n[00:33.26]The Milky Way we're renegading \n[00:35.18]Yeah yeah yeah yeah yeah \n[00:37.02]I got you moonlight you're my starlight \n[00:41.77]I need you all night \n[00:44.36]Come on dance with me \n[00:46.11]I'm levitating \n[00:46.87]You moonlight you're my starlight \n[00:51.10]I need you all night \n[00:53.63]Come on dance with me \n[00:55.39]I'm levitating \n[01:00.74]I believe that you're for me I feel it in our energy \n[01:03.08]I see us written in the stars \n[01:05.45]We can go wherever so let's do it now \n[01:07.22]Or never baby nothings ever ever too far \n[01:10.05]Glitter in the sky \n[01:11.22]Glitter in our eyes \n[01:12.33]Shining just the way we are \n[01:14.70]I feel like we re forever every time we get together \n[01:16.92]But whatever let's get lost on Mars \n[01:19.90]You want me I want you baby \n[01:22.08]My sugarboo I'm levitating \n[01:24.48]The Milky Way we're renegading \n[01:26.50]Yeah yeah yeah yeah yeah \n[01:28.23]I got you moonlight you're my starlight \n[01:33.00]I need you all night \n[01:35.64]Come on dance with me \n[01:37.22]I'm levitating \n[01:38.08]You moonlight you're my starlight \n[01:42.27]I need you all night \n[01:45.00]Come on dance with me \n[01:46.73]I'm levitating \n[01:47.99]You can fly away with me tonight \n[01:50.27]You can fly away with me tonight \n[01:52.58]Baby let me take you for a ride \n[01:54.55]Yeah yeah yeah yeah yeah \n[01:55.93]I'm levitating \n[01:57.20]You can fly away with me tonight \n[01:59.58]You can fly away with me tonight \n[02:01.98]Baby let me take you for a ride \n[02:03.79]Yeah yeah yeah yeah yeah \n[02:05.77]My love is like a rocket watch it blast off \n[02:08.14]And I'm feeling so electric dance my a** off \n[02:10.54]And even if I wanted to I can't stop \n[02:12.87]Yeah yeah yeah yeah yeah \n[02:15.16]My love is like a rocket watch it blast off \n[02:17.23]And I'm feeling so electric dance my a** off \n[02:19.87]And even if I wanted to I can't stop \n[02:22.14]Yeah yeah yeah yeah yeah \n[02:25.09]You want me I want you baby \n[02:27.26]My sugarboo I'm levitating \n[02:29.73]The Milky Way we're renegading \n[02:33.52]I got you moonlight you're my starlight \n[02:38.17]I need you all night \n[02:40.90]Come on dance with me \n[02:42.58]I'm levitating \n[02:43.80]You can fly away with me tonight \n[02:46.27]You can fly away with me tonight \n[02:48.51]Baby let me take you for a ride \n[02:50.34]Yeah yeah yeah yeah yeah \n[02:51.85]I'm levitating \n[02:53.10]You can fly away with me tonight \n[02:55.43]You can fly away with me tonight \n[02:57.86]Baby let me take you for a ride \n[02:59.63]Yeah yeah yeah yeah yeah \n[03:01.40]I got you moonlight you're my starlight \n[03:06.20]I need you all night \n[03:08.87]Come on dance with me \n[03:10.47]I'm levitating \n[03:11.28]You moonlight you're my starlight \n[03:15.55]I need you all night \n[03:18.17]Come on dance with me \n[03:19.85]I'm levitating",
  //       },
  //     ),
  //   ),
  //   AudioSource.uri(
  //     Uri.parse(
  //         "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
  //     tag: MediaItem(
  //       id: '${_nextMediaId++}',
  //       album: "Science Friday",
  //       title: "A Salute To Head-Scratching Science",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //       extras: {},
  //     ),
  //   ),
  //   AudioSource.uri(
  //     Uri.parse("https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
  //     tag: MediaItem(
  //       id: '${_nextMediaId++}',
  //       album: "Science Friday",
  //       title: "From Cat Rheology To Operatic Incompetence",
  //       artUri: Uri.parse(
  //           "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
  //       extras: {},
  //     ),
  //   )
  // ]);

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

  APIRequestStatus _apiPlaylistRequestStatus = APIRequestStatus.unInitialized;
  get getApiPlaylistRequestStatus => _apiPlaylistRequestStatus;

  fetchPlaylist() async {
    setApiPlaylistRequestStatus(APIRequestStatus.loading);

    Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var url = Constants.appPlaylistURL;
    List<AudioSource> _audioItems = [];

    try {
      final res = await dio.get(url);
      if (res.statusCode == 200) {
        // TODO This can be a PODO.
        List raw = res.data;
        raw.forEach(
          (ele) {
            _audioItems.add(
              AudioSource.uri(
                Uri.parse(ele['audiourl']),
                tag: MediaItem(
                  id: '${_nextMediaId++}',
                  album: ele['album'],
                  title: ele['title'],
                  artUri: Uri.parse(ele['artUri']),
                  extras: {'lyrics': ele['extras']['lyrics'] ?? ""},
                ),
              ),
            );
          },
        );

        playlist = ConcatenatingAudioSource(children: _audioItems);
        initPlayer();
        setApiPlaylistRequestStatus(APIRequestStatus.loaded);
      } else
        setApiPlaylistRequestStatus(APIRequestStatus.error);
    } catch (e) {
      print(e);
      setApiPlaylistRequestStatus(APIRequestStatus.error);
    }
  }

  setApiPlaylistRequestStatus(APIRequestStatus status) {
    _apiPlaylistRequestStatus = status;
    notifyListeners();
  }

  //lyrics
  List<Lyric> lyrics = [];

  lyricsParse(lrc) {
    lrc = lrc.replaceAll("\r", "");
    RegExp reg = RegExp(r"""\[(.*?):(.*?)\](.*?)\n""");
    Iterable<Match> matches;
    try {
      matches = reg.allMatches(lrc);
    } catch (e) {
      // we assume everything works!
      print(e.toString());
    }

    List list = matches.toList();
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        var temp = list[i];
        var title = list[i][3];
        lyrics.add(Lyric(
          title,
          startTime: lyricTimeToDuration("${temp[1]}:${temp[2]}"),
        ));
      }
    }

    lyrics.removeWhere((lyric) => lyric.lyric.trim().isEmpty);
    for (int i = 0; i < lyrics.length - 1; i++) {
      lyrics[i].endTime = lyrics[i + 1].startTime;
    }
    lyrics.last.endTime = Duration(hours: 200);
  }

  Duration lyricTimeToDuration(String time) {
    int seperatorIdx = time.indexOf(":");
    var minutes = time.substring(0, seperatorIdx);
    var seconds = time.substring(seperatorIdx + 1, seperatorIdx + 3);
    return Duration(minutes: int.parse(minutes), seconds: int.parse(seconds));
  }

  lyricByDuration(Duration curDuration) {
    for (int i = 0; i < lyrics.length; i++) {
      if (curDuration >= lyrics[i].startTime &&
          curDuration < lyrics[i].endTime) {
        return {'idx': i, 'lyric': lyrics[i].lyric};
      }
    }
    return {'idx': 0, 'lyric': ''};
  }
}

class Lyric {
  String lyric;
  Duration startTime;
  Duration endTime;

  Lyric(this.lyric, {this.startTime, this.endTime});
}
