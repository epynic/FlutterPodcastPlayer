import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyRouter {
  static Future pushPage(BuildContext context, Widget page, routeName) {
    var val = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
        settings: RouteSettings(name: routeName),
      ),
    );

    return val;
  }

  static pushPageReplacement(BuildContext context, Widget page, routeName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
        settings: RouteSettings(name: routeName),
      ),
    );
  }
}
