import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.blueGrey.withOpacity(0.2),
      child: Row(
        children: [
          _thumbnail('assets/doge.png'),
          _title(),
          Expanded(
            child: _play(),
          ),
        ],
      ),
    );
  }

  _play() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Icon(
          Icons.play_arrow,
          size: 45,
        ),
      ),
    );
  }

  _title() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Track 1'),
        Text(
          'Album Name',
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  _thumbnail(img) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Image.asset(
        img,
      ),
    );
  }
}
