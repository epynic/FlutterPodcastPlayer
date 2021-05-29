import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './view_models/app_provider.dart';
import './utils/theme_config.dart';
import './views/audio_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        return MaterialApp(
          darkTheme: ThemeConfig.darkTheme,
          theme: appProvider.theme,
          title: 'Welcome to Flutter',
          home: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.bookmark_border),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(Icons.more_vert),
                )
              ],
            ),
            body: AudioPage(),
          ),
        );
      },
    );
  }
}
