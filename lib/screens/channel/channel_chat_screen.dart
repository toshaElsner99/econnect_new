import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/screens/channel/channel_member_info_screen/channel_members_info.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/channel_list_provider.dart';
import '../../utils/app_color_constants.dart';

class ChannelChatScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  const ChannelChatScreen({super.key,required this.channelId,required this.channelName});

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChannelChatProvider>(context, listen: false).getChannelInfoApiCall(channelId: widget.channelId);
      Provider.of<ChannelListProvider>(context, listen: false).readUnReadChannelMessage(oppositeUserId: widget.channelId,isCallForReadMessage: true);
      Provider.of<ChannelChatProvider>(context, listen: false).getChannelChatApiCall(channelId: widget.channelId);
    },);
   }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          titleSpacing: 0,
          leading: IconButton(onPressed: () => pop(), icon: Icon(CupertinoIcons.back)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonText(text: widget.channelName,maxLines: 1,fontSize: 14),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(AppImage.person,height: 16,width: 16,color: AppColor.borderColor,),
                  const SizedBox(width: 2),
                  commonText(text: "${channelChatProvider.getChannelInfo?.data?.members?.length ?? 0}",fontSize: 15,color: AppColor.borderColor,fontWeight: FontWeight.w500),
                  GestureDetector(
                    // onTap: () => pushScreen(screen: /*PinnedPostsScreen(userName: widget.userName, oppositeUserId: widget.oppositeUserId)*/),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(AppImage.pinTiltIcon, height: 15, width: 15, color: AppColor.borderColor),
                          const SizedBox(width: 2),
                          commonText(
                            text: "${channelChatProvider.getChannelInfo?.data!.pinnedMessagesCount}",
                            fontSize: 16,
                            color: AppColor.borderColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ],),
                    ),
                  ),
                  Image.asset(AppImage.fileIcon, height: 18, width: 15, color: AppColor.borderColor),
                ],
              )
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info, color: AppColor.whiteColor),
              // onPressed: () => pushScreen(screen: ChannelMembersInfo(channelId: widget.channelId, channelName: widget.channelName)),
              onPressed: () {
                print("Channel Tapped");
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChannelMembersInfo(channelId: widget.channelId, channelName: widget.channelName)));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Divider(color: Colors.grey.shade800, height: 1,),

          ],
        ),
      );
    },);
  }


}
