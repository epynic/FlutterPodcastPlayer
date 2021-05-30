import 'package:flutter/material.dart';
import './widget_loading.dart';
import './widget_error.dart';
import './enums.dart';

class BodyBuilder extends StatelessWidget {
  final APIRequestStatus apiRequestStatus;
  final Widget child;
  final Function reload;

  BodyBuilder(
      {Key key,
      @required this.apiRequestStatus,
      @required this.child,
      @required this.reload})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    switch (apiRequestStatus) {
      case APIRequestStatus.loading:
        return MyLoadingWidget();
        break;
      case APIRequestStatus.unInitialized:
        return MyLoadingWidget();
        break;
      case APIRequestStatus.error:
        return MyErrorWidget(
          reload: reload,
        );
        break;

      case APIRequestStatus.loaded:
        return child;
        break;
      default:
        return MyLoadingWidget();
    }
  }
}
