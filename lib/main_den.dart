// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import './view_models/app_provider.dart';
// import './view_models/audio_provider.dart';
// import './views/splash.dart';
// import './utils/theme_config.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AppProvider()),
//         ChangeNotifierProvider(create: (_) => AudioProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppProvider>(
//       builder: (BuildContext context, AppProvider appProvider, Widget child) {
//         return MaterialApp(
//           darkTheme: ThemeConfig.darkTheme,
//           theme: appProvider.theme,
//           title: 'Welcome to Flutter',
//           home: Splash(),
//         );
//       },
//     );
//   }
// }
