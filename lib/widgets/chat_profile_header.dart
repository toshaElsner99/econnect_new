import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';


class ChatProfileHeader extends StatelessWidget {
  final String userId;
  final String userName;
  final String userImageUrl;
  final String userStatus;

  const ChatProfileHeader({
    super.key,
    required this.userId,
    required this.userName,
    required this.userStatus,
    required this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          profileIconWithStatus(
            userID: userId,
            status: userStatus,
            userName: userName,
            otherUserProfile: userImageUrl,
            radius: 60,
            iconSize: 25,
            containerSize: 20,
          ),
          const SizedBox(height: 12),
          commonText(
            text: userName,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          commonText(
            text:
            'This is the start of your conversation\nwith $userName. Messages and files\nshared here are not shown to anyone\nelse.',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.normal,
            fontSize: 15,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}
