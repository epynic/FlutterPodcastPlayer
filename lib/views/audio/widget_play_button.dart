import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast_player/utils/theme_config.dart';
import 'package:provider/provider.dart';
import '../../view_models/audio_provider.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: Provider.of<AudioProvider>(context).player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(2.0),
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(strokeWidth: 1),
          );
        } else if (playing != true) {
          return _playWrap(
            IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: ThemeConfig.buttonBG,
              ),
              onPressed: Provider.of<AudioProvider>(context).player.play,
            ),
          );
        } else if (processingState != ProcessingState.completed) {
          return _playWrap(
            IconButton(
                icon: Icon(Icons.pause),
                onPressed: Provider.of<AudioProvider>(context).player.pause),
          );
        } else {
          return _playWrap(
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: () => Provider.of<AudioProvider>(context).player.seek(
                  Duration.zero,
                  index: Provider.of<AudioProvider>(context)
                      .player
                      .effectiveIndices
                      .first),
            ),
          );
        }
      },
    );
  }

  _playWrap(icon) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          width: 2,
          color: ThemeConfig.buttonBG,
        ),
      ),
      child: Center(
        child: icon,
      ),
    );
  }
}
