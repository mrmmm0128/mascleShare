import 'package:flutter/material.dart';

class ShowHistory extends StatelessWidget {
  const ShowHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 209, 209, 0),
          title: Text(
            'your workout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("show your workout here")],
        ),
      ),
    );
  }
}
