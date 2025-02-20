import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_color_constants.dart';
import '../../../utils/common/common_widgets.dart';

class PinnedPostsScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  const PinnedPostsScreen({super.key,required this.userName,required this.oppositeUserId});

  @override
  State<PinnedPostsScreen> createState() => _PinnedPostsScreenState();
}

class _PinnedPostsScreenState extends State<PinnedPostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Divider(color: Colors.grey.shade800, height: 1),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            commonText(text: "Pinned Posts", fontSize: 16),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: commonText(
                text: " | ${widget.userName}",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColor.borderColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}
