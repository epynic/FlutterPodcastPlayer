import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}
