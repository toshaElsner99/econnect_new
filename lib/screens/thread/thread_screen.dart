import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Thread Screen'),
      ),
    );
  }
}
