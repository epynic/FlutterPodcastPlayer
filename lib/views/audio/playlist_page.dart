import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../view_models/audio_provider.dart';
import '../../utils/const.dart';
import '../../utils/body_builder.dart';
import '../../utils/router.dart';
import './audio_page.dart';
import './widget_mini_player.dart';

class AudioPlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true, title: Text(Constants.appName), elevation: 1),
      body: BodyBuilder(
        apiRequestStatus:
            Provider.of<AudioProvider>(context).getApiPlaylistRequestStatus,
        reload:
            Provider.of<AudioProvider>(context, listen: false).fetchPlaylist,
        child: _body(context),
      ),
      bottomNavigationBar: Provider.of<AudioProvider>(context).showMiniPlayer()
          ? AnimatedContainer(
              duration: Duration(seconds: 10),
              curve: Curves.fastLinearToSlowEaseIn,
              child: MiniPlayer(),
            )
          : SizedBox(),
    );
  }

  _body(context) {
    return Container(
      child: StreamBuilder<SequenceState>(
        stream: Provider.of<AudioProvider>(context).player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final sequence = state?.sequence ?? [];
          return ListView(
            children: [
              for (var i = 0; i < sequence.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black26,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(sequence[i].tag.title as String),
                    onTap: () {
                      MyRouter.pushPage(
                          context, AudioPage(playIndex: i), 'audioPage');
                      // Provider.of<AudioProvider>(context)
                      //     .player
                      //     .seek(Duration.zero, index: i);
                    },
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
