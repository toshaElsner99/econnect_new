import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var commonCubit = CommonCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("INITILIZED>>> ");
    commonCubit.getUserByIDCall();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [


      ],),
    );
  }
}
