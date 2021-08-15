import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:podcast_player/utils/const.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../view_models/audio_provider.dart';
import './widget_play_button.dart';
import 'package:provider/provider.dart';
import '../../utils/theme_config.dart';

class AudioPage extends StatefulWidget {
  final playIndex;
  final bool autoPlay;

  const AudioPage({Key key, this.playIndex, this.autoPlay = true})
      : super(key: key);
  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage>
    with SingleTickerProviderStateMixin {
  bool showLyrics = false;
  bool lyricsAvailable = false;

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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initAudioStream();
    });
  }

  @override
  void dispose() {
    showAnimateController.dispose();
    super.dispose();
  }

  String streamTitle = Constants.audioPageLoadingTitle;
  String streamMediaArt = Constants.audioPageLoadingArt;
  String streamLyrics = "";

  final ItemScrollController lyricScrollController = ItemScrollController();
  int itemScrollIndex = 0;
  int itemOffset = 3; // update if (index == 0 || index == 1 || index == 2)

  _initAudioStream() {
    // start playing
    if (widget.autoPlay)
      Provider.of<AudioProvider>(context, listen: false)
          .startPlaying(index: widget.playIndex);

    // stream sequencestate listen
    Provider.of<AudioProvider>(context, listen: false)
        .player
        .sequenceStateStream
        .listen((event) {
      final tx = event.currentSource.tag as MediaItem;
      streamTitle = tx.title;
      streamMediaArt = tx.artUri.toString();
      streamLyrics = tx.extras['lyrics'] ?? "";

      itemScrollIndex = 0;

      if (streamLyrics == '')
        lyricsAvailable = false;
      else {
        lyricsAvailable = true;
        Provider.of<AudioProvider>(context, listen: false)
            .lyricsParse(streamLyrics);
      }

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(streamTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: double.infinity),
          AnimatedContainer(
            duration: animationTime,
            curve: animationCurve,
            margin: EdgeInsets.only(bottom: 30),
            height: showLyrics ? 200 : 300,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CachedNetworkImage(imageUrl: streamMediaArt),
          ),
          PlayButton(),
          SizedBox(height: 10),
          Expanded(
            child: AnimatedContainer(
              duration: animationTime,
              child: showLyrics ? _lyrics() : _lyrics(),
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

  scrollLyric(lyric) {
    return Container(
      child: ScrollablePositionedList.builder(
        itemCount:
            Provider.of<AudioProvider>(context, listen: false).lyrics.length +
                itemOffset,
        itemBuilder: (context, index) => scrollLyricItem(index, lyric),
        itemScrollController: lyricScrollController,
      ),
    );
  }

  scrollLyricItem(index, lyric) {
    if (index == 0 || index == 1 || index == 2)
      return ListTile(title: Text(""));

    if (itemScrollIndex != lyric['idx']) {
      itemScrollIndex = lyric['idx'];
      lyricScrollController.scrollTo(
          index: itemScrollIndex, duration: Duration(milliseconds: 400));
    }

    return ListTile(
      title: Text(
        Provider.of<AudioProvider>(context, listen: false)
            .lyrics[index - itemOffset]
            .lyric,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: (index == lyric['idx'] + itemOffset) ? 24 : 14),
      ),
    );
  }

  singleLineLyric(txt) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Text(
          txt,
          style: TextStyle(
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _lyrics() {
    return StreamBuilder<Duration>(
      stream: Provider.of<AudioProvider>(context).player.positionStream,
      builder: (context, snapshot) {
        final duration =
            (snapshot.data == null || snapshot.data.inSeconds == null)
                ? 0
                : snapshot.data.inSeconds;

        final lyric = Provider.of<AudioProvider>(context, listen: false)
            .lyricByDuration(Duration(seconds: duration ?? 0));

        if (!lyricsAvailable) {
          return Container(
            child: Center(
              child: Text(
                Constants.audioPageNoLyric,
                style: TextStyle(fontSize: 30),
              ),
            ),
          );
        }
        return !showLyrics
            ? singleLineLyric(lyric['lyric'])
            : scrollLyric(lyric);
      },
    );
  }
}
