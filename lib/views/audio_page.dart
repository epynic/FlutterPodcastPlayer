import 'package:flutter/material.dart';
import '../utils/theme_config.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                showAnimateController.reverse();
              else
                showAnimateController.forward();
            },
            child: AnimatedIcon(
              icon: AnimatedIcons.close_menu,
              progress: showAnimateController,
            ),
          ),
        )
      ],
    );
  }
}
