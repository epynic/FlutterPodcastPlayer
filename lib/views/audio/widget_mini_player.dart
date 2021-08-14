import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:podcast_player/utils/router.dart';
import 'package:podcast_player/view_models/audio_provider.dart';
import 'package:podcast_player/views/audio/audio_page.dart';
import 'package:podcast_player/views/audio/widget_play_button.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.blueGrey.withOpacity(0.2),
      child: StreamBuilder<SequenceState>(
        stream: Provider.of<AudioProvider>(context).player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == null || state.sequence.isEmpty ?? true)
            return SizedBox();
          final metadata = state.currentSource.tag as MediaItem;
          return Row(
            children: [
              _thumbnail(metadata.artUri.toString()),
              GestureDetector(
                onTap: () => MyRouter.pushPage(
                    context, AudioPage(autoPlay: false), 'audioPage'),
                child: Container(
                  width: MediaQuery.of(context).size.width * .65,
                  child: _title(title: metadata.title, album: metadata.album),
                ),
              ),
              Expanded(
                child: _play(context),
              ),
            ],
          );
        },
      ),
    );
  }

  _play(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: PlayButton(),
    );
  }

  _title({title, album}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, overflow: TextOverflow.ellipsis),
        Text(
          album,
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  _thumbnail(img) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 10, right: 10),
      child: CachedNetworkImage(
        imageUrl: img,
      ),
    );
  }
}
