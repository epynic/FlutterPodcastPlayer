// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../view_models/audio_provider.dart';
// import '../../utils/const.dart';
// import '../../utils/body_builder.dart';
// import './audio_page.dart';
// import './widget_mini_player.dart';

// class AudioPlaylistPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(Constants.appName),
//         elevation: 1,
//       ),
//       body: BodyBuilder(
//         apiRequestStatus:
//             Provider.of<AudioProvider>(context).getApiPlaylistRequestStatus,
//         reload:
//             Provider.of<AudioProvider>(context, listen: false).fetchPlaylist,
//         child: _body(context),
//       ),
//       bottomNavigationBar: MiniPlayer(),
//     );
//   }

//   _body(context) {
//     return Container(
//       child: ListView.builder(
//         itemCount: Provider.of<AudioProvider>(context, listen: false)
//             .audioItems
//             .length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             onTap: () => _playTap(index, context),
//             title: Text(
//               '${index + 1}. ' +
//                   Provider.of<AudioProvider>(context, listen: false)
//                       .audioItems[index]
//                       .title,
//               overflow: TextOverflow.ellipsis,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   _playTap(index, context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AudioPage(),
//       ),
//     );
//   }
// }
