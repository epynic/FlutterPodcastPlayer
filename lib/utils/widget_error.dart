import 'package:flutter/material.dart';

class MyErrorWidget extends StatelessWidget {
  final Function reload;

  const MyErrorWidget({Key key, this.reload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Center(
        child: GestureDetector(
          onTap: reload,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_sharp, size: 45),
              SizedBox(height: 10),
              Text(
                'Somethings in life dont work the way we want',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              Text('Tap to retry'),
            ],
          ),
        ),
      ),
    );
  }
}
