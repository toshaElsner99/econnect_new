import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/screens/channel/reply_message_screen_channel/reply_message_screen_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../model/channel_pinned_message_model.dart';
import '../../../providers/download_provider.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';
import '../../../utils/common/common_function.dart';
import '../../../utils/common/common_widgets.dart';

class ChannelPinnedPostsScreen extends StatefulWidget {
  final String channelName;
  final String channelId;

  const ChannelPinnedPostsScreen(
      {super.key, required this.channelName, required this.channelId,});

  @override
  State<ChannelPinnedPostsScreen> createState() => _ChannelPinnedPostsScreenState();
}

class _ChannelPinnedPostsScreenState extends State<ChannelPinnedPostsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChannelChatProvider>(context, listen: false).getChannelPinnedMessage(channelID: widget.channelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Cw.commonBackButton(),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Divider(color: Colors.grey.shade800, height: 1),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Cw.commonText(text: "Pinned Posts", fontSize: 16),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Cw.commonText(
                text: " | ${widget.channelName}",
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
          Divider(color: Colors.grey.shade800, height: 1,),
          Expanded(child: ListView(children: [
            dateHeaders(),
          ],))
        ],
      ),
    );
  }

  Widget dateHeaders() {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      return channelChatProvider.messageGroups.isEmpty? SizedBox.shrink() :
      channelChatProvider.channelPinnedMessageModel?.data?.messages!.length == 0 ?
      Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImage.pinIcon,
              height: 60,
              width: 60,
              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.appBarColor,
            ),
            const SizedBox(height: 16),
            Cw.commonText(
              text: "No pinned posts yet",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.whiteColor,
            ),
            const SizedBox(height: 12),
            Cw.commonText(
              text: "Pin important messages which are visible to the whole channel. Open the context menu on a message and choose Pin to Channel to save it here.",
              textAlign: TextAlign.center,
              fontSize: 14,
              color: AppColor.borderColor,
              height: 1.5,
            ),
          ],
        ),
      ) :
      ListView.builder(
        shrinkWrap: true,
        reverse: false,
        physics: NeverScrollableScrollPhysics(),
        itemCount: channelChatProvider.channelPinnedMessageModel?.data?.messages?.length ?? 0,
        itemBuilder: (itemContext, index) {
          final pinnedMessageList = channelChatProvider.channelPinnedMessageModel?.data?.messages?[index];
          String? previousSenderId;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColor.blueColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Cw.commonText(
                        text: Cf.instance.formatDateWithYear(pinnedMessageList?.sId ?? ""),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: pinnedMessageList?.messagesDetails?.length ?? 0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  MessageDetail? message = pinnedMessageList?.messagesDetails?[index];
                  bool showUserDetails = previousSenderId != message!.senderId;
                  previousSenderId = message.senderId;
                  return chatBubble(
                    index: index,
                    messageList: message,
                    showUserDetails: true,
                    userId: message.senderId ?? "",
                    messageId: pinnedMessageList!.messagesDetails![index].sId.toString(),
                    message: message.content ?? "",
                    time: DateTime.parse(message.createdAt.toString()).toString(),
                  );
                },
              )
            ],
          );
        },
      );
    });
  }
  Widget chatBubble({
    required int index,
    required MessageDetail messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
    bool showUserDetails = true,
  })  {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      return Container(
        margin: EdgeInsets.only(top: 1),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (showUserDetails) ...{
                  /// Profile  Section ///
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.5),
                    child: Cw.profileIconWithStatus(userID: messageList.senderInfo?.sId ?? "", status: messageList.senderInfo?.status ?? "offline",otherUserProfile: messageList.senderInfo?.thumbnailAvatarUrl ?? "",radius: 17,userName: messageList.senderInfo?.username ?? ""),
                  )
                } else ...{
                  SizedBox(width: 50)
                },
                if (showUserDetails) SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showUserDetails)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Cw.commonText(height: 1.2, text: messageList.senderInfo?.username ?? "", fontWeight: FontWeight.bold),
                            Visibility(
                              visible: (messageList.senderInfo?.customStatusEmoji != "" && messageList.senderInfo?.customStatusEmoji != null)? true : false,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: CachedNetworkImage(
                                  width: 20,
                                  height: 20,
                                  imageUrl: messageList.senderInfo?.customStatusEmoji ?? "",
                                ),),
                            ),
                            Padding(padding: const EdgeInsets.only(left: 5.0),
                              child: Cw.commonText(height: 1.2, text: Cf.instance.formatTime(time), color: Colors.grey, fontSize: 12),
                            ),
                            Spacer(),
                            Container(
                              height: 35,
                              child: PopupMenuButton<String>(
                                color: AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : AppColor.appBarColor,
                                offset: Offset(-20, 10),
                                onSelected: (value) {
                                  if (value == 'unpin') {
                                    channelChatProvider.unPinOnlyFromPinnedMessages(channelID: widget.channelId, messageId: messageId);
                                    // chatProvider.pinUnPinMessage(receiverId: widget.oppositeUser Id, messageId: messageId, pinned: false, callForUnpinPostOnly: true);
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'unpin',
                                    height: 30,
                                    child: Row(
                                      children: [
                                        Image.asset(AppImage.pinTiltIcon, height: 20, width: 20, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black),
                                        SizedBox(width: 10),
                                        Cw.commonText(text: 'Unpin from Channel', color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                                icon: Icon(Icons.more_vert),
                              ),
                            ),
                          ],
                        ),
                      Visibility(
                          visible: message.isNotEmpty,
                          child: Cw.commonHTMLText(message: message)),
                      Visibility(
                          visible: messageList.isForwarded ?? false,
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            padding: EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.borderColor,width: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.forwardColor : Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Cw.commonText(text: "Forwarded",color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor,fontWeight: FontWeight.w500),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(children: [
                                    Cw.profileIconWithStatus(userID: messageList.senderOfForward?.sId ?? "", status: messageList.senderOfForward?.status ?? "offline" ,needToShowIcon: false,otherUserProfile: messageList.senderOfForward?.thumbnailAvatarUrl ?? "",userName: messageList.senderOfForward?.username ?? ""),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Cw.commonText(text: messageList.senderOfForward?.username ?? "unknown"),
                                          SizedBox(height: 3),
                                          Cw.commonText(text: Cf.instance.formatDateString(messageList.forwards?.createdAt ?? ""),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                Cw.commonHTMLText(message: "${messageList.forwards?.content}"),
                                Visibility(
                                  visible: messageList.forwards?.files?.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwards?.files?.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwards?.files?[index];
                                      String originalFileName = Cf.instance.getFileName(messageList.forwards!.files?[index]);
                                      String formattedFileName = Cf.instance.formatFileName(originalFileName);
                                      String fileType = Cf.instance.getFileExtension(originalFileName);
                                      return Container(
                                        margin: EdgeInsets.only(top: 5,right: 10),
                                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColor.lightGreyColor),
                                        ),
                                        child: Row(
                                          children: [
                                            Cf.instance.getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                            SizedBox(width: 20,),
                                            Flexible(
                                                flex: 10,
                                                fit: FlexFit.loose,
                                                child: Cw.commonText(text: formattedFileName,maxLines: 1)),
                                            Spacer(),
                                            GestureDetector(
                                                onTap: () => Provider.of<DownloadFileProvider>(context,listen: false).downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
                                                child: Image.asset(AppImage.downloadIcon,fit: BoxFit.contain,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))
                                          ],
                                        ),
                                      );
                                    },),
                                ),

                              ],),

                          )
                      ),
                      Visibility(
                        visible: messageList.files?.length != 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files?.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files?[index];
                            String originalFileName = Cf.instance.getFileName(messageList.files![index]);
                            String formattedFileName = Cf.instance.formatFileName(originalFileName);
                            String fileType = Cf.instance.getFileExtension(originalFileName);
                            // IconData fileIcon = getFileIcon(fileType);
                            return Container(
                              margin: EdgeInsets.only(top: 4,right: 10),
                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.lightGreyColor),
                              ),
                              child: Row(
                                children: [
                                  Cf.instance.getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                  SizedBox(width: 20,),
                                  Flexible(
                                      flex: 10,
                                      fit: FlexFit.loose,
                                      child: Cw.commonText(text: formattedFileName,maxLines: 1)),
                                  Spacer(),
                                  GestureDetector(
                                      onTap: () => Provider.of<DownloadFileProvider>(context,listen: false).downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
                                      child: Image.asset(AppImage.downloadIcon,fit: BoxFit.contain,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))
                                ],
                              ),
                            );
                          },),
                      ),
                      Visibility(
                        visible: messageList.replies?.isNotEmpty ?? false,
                        child: GestureDetector(
                          onTap: () {
                            print("Simple Passing = ${messageId.toString()}");
                            Cf.instance.pushScreen(screen:
                              ReplyMessageScreenChannel(channelId: widget.channelId, channelName: widget.channelName, msgID: messageId,),
                            ).then((value) {
                              print("value>>> $value");
                            });},
                          child: Container(
                            // color: Colors.red,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                // 🖼️ Overlapping profile images
                                if (messageList.repliesSenderInfo != null && messageList.repliesSenderInfo!.isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(right :messageList.repliesSenderInfo!.length > 1 ? 22 : 7),
                                    // color: Colors.amber,
                                    child: Row(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Cw.profileIconWithStatus(
                                              userName: messageList.repliesSenderInfo?[0].username ?? "",
                                              userID: messageList.repliesSenderInfo?[0].sId ?? "",
                                              status: "",
                                              needToShowIcon: false,
                                              radius: 12,
                                              otherUserProfile: messageList.repliesSenderInfo?[0].thumbnailAvatarUrl ?? "",
                                            ),
                                            if (messageList.repliesSenderInfo!.length > 1)
                                              Positioned(
                                                left: 16,
                                                child: Cw.profileIconWithStatus(
                                                  userName: messageList.repliesSenderInfo?[1].sId ?? "",
                                                  userID: messageList.repliesSenderInfo?[1].sId ?? "",
                                                  status: "",
                                                  needToShowIcon: false,
                                                  radius: 12,
                                                  otherUserProfile: messageList.repliesSenderInfo?[1].thumbnailAvatarUrl ?? "",
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(left: 0.0,right: 4.0),
                                  child: Transform.flip(
                                    flipX: true,
                                    child: Image.asset(
                                      AppImage.forwardIcon,
                                      height: 15,
                                      width: 15,
                                      color: AppColor.borderColor,
                                    ),
                                  ),
                                ),

                                Cw.commonText(
                                  text: "${messageList.replyCount} ${messageList.replyCount! > 1 ? 'replies' : 'reply'}",
                                  fontSize: 12,
                                  color: AppColor.borderColor,
                                ),

                                SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Cw.commonText(
                                      text: Cf.instance.getTimeAgo(
                                          (messageList.replies != null && messageList.replies!.isNotEmpty)
                                              ? messageList.replies!.last.createdAt.toString()
                                              : DateTime.now().toString()
                                      ),
                                      fontSize: 10,
                                      color: AppColor.borderColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },);
  }
}