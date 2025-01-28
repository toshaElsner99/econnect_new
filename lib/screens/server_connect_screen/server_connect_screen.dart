import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../cubit/server_connect/server_connect_cubit.dart';

class ServerConnectScreen extends StatefulWidget {
  const ServerConnectScreen({super.key});

  @override
  State<ServerConnectScreen> createState() => _ServerConnectScreenState();
}

class _ServerConnectScreenState extends State<ServerConnectScreen> {
  var serverConnectCubit = ServerConnectCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(text: AppString.welcome,fontSize: 22,fontWeight: FontWeight.w600),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: commonText(text: AppString.connectTOServer,fontSize: 28,fontWeight: FontWeight.w800,height: 1.1),
            ),
            commonText(text: AppString.serverIsYourCommunicationHub,fontWeight: FontWeight.w500),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: commonTextFormField(controller: serverConnectCubit.serverUrlController, hintText: AppString.enterServerUrl),
            ),
            commonTextFormField(controller: serverConnectCubit.serverUrlController, hintText: AppString.displayName),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: commonElevatedButton(onPressed: () {}, buttonText: AppString.connect),
            )
          ],
        ),
      ),
    );
  }
}
