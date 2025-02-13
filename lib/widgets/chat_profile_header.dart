import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';

import 'chat_header_buttons.dart';

class ChatProfileHeader extends StatelessWidget {
  final String userName;
  final String userImageUrl;

  ChatProfileHeader({required this.userName, required this.userImageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Profile Image with Check Icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userImageUrl),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColor.blackColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColor.greenColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColor.whiteColor,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Name
              commonText(
                  text: userName,
                  // color: AppColor.whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              // Description
              commonText(
                  text:
                      'This is the start of your conversation\nwith Tosha Shah. Messages and files\nshared here are not shown to anyone\nelse.',
                  textAlign: TextAlign.center,
                  // color:AppColor.whiteColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  height: 1.5),
            ],
          ),
        ),
        // Add the header buttons here
        // ChatHeaderButtons(),
      ],
    );
  }
}
