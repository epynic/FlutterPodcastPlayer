import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
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

  String streamTitle = '🎸🤘';
  String streamMediaArt =
      'https://img1.od-cdn.com/ImageType-100/0211-1/%7B9C6C5E2A-A7CE-45C8-B940-04032771C3F5%7DImg100.jpg';

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
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(streamTitle),
        actions: _appBarActions(),
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
            child: CachedNetworkImage(imageUrl: streamMediaArt),
          ),
          PlayButton(),
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

  _appBarActions() {
    return [
      Padding(
        padding: EdgeInsets.all(5),
        child: Icon(Icons.bookmark_border),
      ),
      Padding(
        padding: EdgeInsets.all(15),
        child: Icon(Icons.more_vert),
      )
    ];
  }
}
