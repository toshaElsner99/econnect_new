import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/channel_chat_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/screens/channel/channel_member_info_screen/channel_members_info.dart';
import 'package:e_connect/screens/channel/files_listing_channel/files_listing_in_channel_screen.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/download_provider.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/app_color_constants.dart';
import '../../utils/app_preference_constants.dart';
import 'channel_info_screen/channel_info_screen.dart';

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
      Provider.of<ChannelChatProvider>(context, listen: false).getChannelMembersList(widget.channelId);
    },);
   }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          titleSpacing: 0,
          leading: commonBackButton(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonText(text: widget.channelName,maxLines: 1,fontSize: 14),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// User Count & navigation ///
                  GestureDetector(
                    onTap: () {
                      if(channelChatProvider.getChannelInfo?.data?.members?.length != 0){
                        pushScreen(screen: ChannelMembersInfo(channelId: widget.channelId, channelName: widget.channelName));
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset(AppImage.person,height: 16,width: 16,color: AppColor.borderColor,),
                        const SizedBox(width: 2),
                        commonText(text: "${channelChatProvider.getChannelInfo?.data?.members?.length ?? 0}",fontSize: 15,color: AppColor.borderColor,fontWeight: FontWeight.w500),

                      ],
                    ),
                  ),
                  /// Pin Messages & navigation ///
                  GestureDetector(
                    // onTap: () => pushScreen(screen: /*PinnedPostsScreen(userName: widget.userName, oppositeUserId: widget.oppositeUserId)*/),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(AppImage.pinTiltIcon, height: 15, width: 15, color: AppColor.borderColor),
                          const SizedBox(width: 3),
                          commonText(
                            text: "${channelChatProvider.getChannelInfo?.data?.pinnedMessagesCount ?? 0}",
                            fontSize: 16,
                            color: AppColor.borderColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ],),
                    ),
                  ),
                  /// File & Navigation ///
                  GestureDetector(
                      onTap: () => pushScreen(screen: FilesListingScreen(channelName: widget.channelName, channelId: widget.channelId)),
                      child: Image.asset(AppImage.fileIcon, height: 18, width: 15, color: AppColor.borderColor)),
                ],
              )
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info, color: AppColor.whiteColor),
              onPressed: () => pushScreen(screen: ChannelInfoScreen(channelId: widget.channelId, channelName: widget.channelName, isPrivate: false,)),
            ),
          ],
        ),
        body: Column(
          children: [
            Divider(color: Colors.grey.shade800, height: 1,),
            Expanded(
              child: ListView(
                // controller: chatProvider.scrollController,
                reverse: true,
                children: [
                  dateHeaders(),
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }
  Widget dateHeaders() {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      List<MessageGroup>? sortedGroups = channelChatProvider.channelChatModel?.data.messages?..sort((a, b) => b.id.compareTo(a.id));
      return channelChatProvider.channelChatModel?.data.messages.length == 0 ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedGroups?.length ?? 0,
        itemBuilder: (itemContext, index) {
          final group = sortedGroups?[index];
          List<Message> sortedMessages = (group?.messages ?? [])..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
                      child: commonText(
                        text: formatDateTime(DateTime.parse(group!.id)),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: sortedMessages.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Message message = sortedMessages[index];
                  bool showUserDetails = previousSenderId != message.senderId;
                  previousSenderId = message.senderId;
                  return chatBubble(
                    index: index,
                    messageList: message,
                    showUserDetails: showUserDetails,
                    userId: message.senderId,
                    messageId: sortedMessages[index].id.toString(),
                    message: message.content,
                    time: DateTime.parse(message.createdAt.toString()).toString(),
                  );
                },
              )
            ],
          );
        },
      );
    },);
  }

  Widget chatBubble({
    required int index,
    required Message messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
    bool showUserDetails = true,
  })  {
    return Consumer2<ChannelChatProvider,CommonProvider>(builder: (context, channelChatProvider,commonProvider, child) {
      // final user = channelChatProvider.getUserById(userId);
      bool pinnedMsg = messageList.isPinned ;
      bool isEdited = messageList.isEdited;
      return Container(
        margin: EdgeInsets.only(top: 1),
        color:  pinnedMsg == true ? AppPreferenceConstants.themeModeBoolValueGet ? Colors.greenAccent.withOpacity(0.15) : AppColor.pinnedColorLight : null,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Column(
          children: [
            Visibility(
                visible: (messageList.isSeen == false && userId != signInModel.data?.user?.id),
                child: newMessageDivider()),
            Visibility(
                visible: pinnedMsg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(AppImage.pinMessageIcon,height: 12,width: 12,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: commonText(text: "Pinned",color: AppColor.blueColor),
                      ),
                    ],
                  ),
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (showUserDetails) ...{
                  /// Profile  Section ///
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.5),
                    child: profileIconWithStatus(userID: messageList.senderInfo.id, status: messageList.senderInfo.status,otherUserProfile: messageList.senderInfo.avatarUrl,radius: 17),
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
                            commonText(height: 1.2, text: messageList.senderInfo.username, fontWeight: FontWeight.bold),
                              Visibility(
                                visible: messageList.senderInfo.customStatusEmoji != "" ? true : false,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: CachedNetworkImage(
                                    width: 20,
                                    height: 20,
                                    imageUrl: messageList.senderInfo.customStatusEmoji ?? "",
                                  ),),
                              ),
                            Padding(padding: const EdgeInsets.only(left: 5.0),
                              child: commonText(height: 1.2, text: formatTime(time), color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      SizedBox(height: 5),
                      Visibility(
                      visible: message.isNotEmpty,
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: commonHTMLText(message: message),
                                  ),
                                  if (isEdited)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(left: 4.0),
                                        // Space between content & label
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          // Ensures compact fit
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 13,
                                              color: AppColor.borderColor,
                                            ),
                                            const SizedBox(width: 2),
                                            commonText(
                                              text: "Edited",
                                              fontSize: 10,
                                              color: AppColor.borderColor,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: messageList.isForwarded,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.borderColor,width: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.forwardColor : Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(text: "Forwarded",color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor,fontWeight: FontWeight.w500),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(children: [
                                    profileIconWithStatus(userID: messageList.senderOfForward?.id ?? "", status: messageList.senderOfForward?.status ?? "offline" ,needToShowIcon: false,otherUserProfile: messageList.senderOfForward?.avatarUrl ?? ""),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          commonText(text: messageList.senderOfForward?.username ?? "unknown"),
                                          SizedBox(height: 3),
                                          commonText(text: formatDateString("${messageList.senderOfForward?.createdAt ?? ""}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                commonHTMLText(message: "${messageList.forwards?.content}"),
                                Visibility(
                                  visible: messageList.forwards?.files.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwards?.files.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwards?.files[index];
                                      String originalFileName = getFileName(messageList.forwards!.files[index]);
                                      String formattedFileName = formatFileName(originalFileName);
                                      String fileType = getFileExtension(originalFileName);
                                      return Container(
                                        margin: EdgeInsets.only(top: 5,right: 10),
                                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColor.lightGreyColor),
                                        ),
                                        child: Row(
                                          children: [
                                            getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                            SizedBox(width: 20,),
                                            Flexible(
                                                flex: 10,
                                                fit: FlexFit.loose,
                                                child: commonText(text: formattedFileName,maxLines: 1)),
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
                        visible: messageList.files.length != 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files[index];
                            String originalFileName = getFileName(messageList.files[index]);
                            String formattedFileName = formatFileName(originalFileName);
                            String fileType = getFileExtension(originalFileName);
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
                                  getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                  SizedBox(width: 20,),
                                  Flexible(
                                      flex: 10,
                                      fit: FlexFit.loose,
                                      child: commonText(text: formattedFileName,maxLines: 1)),
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
                          /*  pushScreenWithTransition(
                              ReplyMessageScreen(
                                userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',
                                messageId: messageId.toString(),
                                receiverId: widget.oppositeUserId,
                              ),
                            ).then((value) {
                              print("value>>> $value");
                              if (messageList.replies != null && messageList.replies!.isNotEmpty) {
                                for (var reply in messageList.replies!) {
                                  if (reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) {
                                    setState(() =>
                                    reply.isSeen = true);
                                  }
                                }
                              }
                            });*/},
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
                                            profileIconWithStatus(
                                              userID: messageList.repliesSenderInfo![0].id,
                                              status: "",
                                              needToShowIcon: false,
                                              radius: 12,
                                              otherUserProfile: messageList.repliesSenderInfo![0].avatarUrl,
                                            ),
                                            if (messageList.repliesSenderInfo!.length > 1)
                                              Positioned(
                                                left: 16,
                                                child: profileIconWithStatus(
                                                  userID: messageList.repliesSenderInfo![1].id,
                                                  status: "",
                                                  needToShowIcon: false,
                                                  radius: 12,
                                                  otherUserProfile: messageList.repliesSenderInfo![1].avatarUrl,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),


                                // 🔴 Red dot circle
                                Visibility(
                                  replacement: SizedBox.shrink(),
                                  visible: true,
                                  // visible: messageList.replies != null && messageList.replies!.isNotEmpty &&
                                  //     messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false),
                                  child: Container(
                                    margin:EdgeInsets.only(right: 5),
                                    width: 10,
                                    height: 10,
                                    // width: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                    // height: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),

                                // 🔄 Reply icon and text
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

                                commonText(
                                  text: "${messageList.replyCount} ${messageList.replyCount > 1 ? 'replies' : 'reply'}",
                                  fontSize: 12,
                                  color: AppColor.borderColor,
                                ),

                                SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: commonText(
                                      text: getTimeAgo(
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
