import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/router.dart';
import '../view_models/audio_provider.dart';
import './audio/page_playlist.dart';

class Splash extends StatefulWidget {
  Splash();
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    pageDefaults();
  }

  pageDefaults() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AudioProvider>(context, listen: false).fetchPlaylist();
      startTimeout();
    });
  }

  startTimeout() async {
    return Timer(Duration(seconds: 2), handleTimeout);
  }

  void handleTimeout() async {
    changeScreen();
  }

  changeScreen() async {
    MyRouter.pushPageReplacement(
        context, AudioPlaylistPage(), 'audioPlaylistPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset(
            'assets/doge.png',
            height: 200,
          ),
        ),
      ),
    );
  }
}
