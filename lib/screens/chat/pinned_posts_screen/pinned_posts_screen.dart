


import 'package:e_connect/providers/chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

import '../../../model/get_user_model.dart';
import '../../../providers/download_provider.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';
import '../../../utils/common/common_function.dart';
import '../../../utils/common/common_widgets.dart';
import '../reply_message_screen/reply_message_screen.dart';

class PinnedPostsScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  final Map<String,dynamic> userCache;

  const PinnedPostsScreen(
      {super.key, required this.userName, required this.oppositeUserId,required this.userCache});

  @override
  State<PinnedPostsScreen> createState() => _PinnedPostsScreenState();
}

class _PinnedPostsScreenState extends State<PinnedPostsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CommonProvider>(context, listen: false).getUserByIDCallForSecondUser (userId: widget.oppositeUserId);
  }

  Map<String, List<PinmessageSecondUser >> _groupMessagesByDate(List<PinmessageSecondUser > messages) {
    Map<String, List<PinmessageSecondUser >> groupedMessages = {};

    for (var message in messages) {
      if (message.createdAt != null) {
        DateTime date = DateTime.parse(message.createdAt!);
        String formattedDate = DateFormat('MMMM dd,yyyy').format(date);
        if (!groupedMessages.containsKey(formattedDate)) {
          groupedMessages[formattedDate] = [];
        }
        groupedMessages[formattedDate]!.add(message);
      }
    }

    return groupedMessages;
  }

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
      body: Consumer2<CommonProvider,ChatProvider>(
        builder: (context, commonProvider,chatProvider, child) {
          final messages = commonProvider.getUserModelSecondUser ?.data?.user?.pinmessage ?? [];
          final groupedMessages = _groupMessagesByDate(messages);

          return ListView.builder(
            itemCount: groupedMessages.keys.length,
            itemBuilder: (context, index) {
              String date = groupedMessages.keys.elementAt(index);
              List<PinmessageSecondUser > messagesForDate = groupedMessages[date]!;
              return Padding(
                padding:  EdgeInsets.only(top: index == 0 ? 10.0 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade600,)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade600)
                          ),
                          child: commonText(text : date, fontWeight: FontWeight.w600, fontSize: 14,),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade600,)),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      itemCount: messagesForDate.length,
                      itemBuilder: (context, index) {
                        final messages = messagesForDate[index];
                        final user = widget.userCache[messages.senderId];
                        return Padding(
                          padding:  EdgeInsets.only(top : index == 0 ? 0 : 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "",otherUserProfile: user?.data!.user!.thumbnailAvatarUrl ?? '',radius: 15,needToShowIcon: false),
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// User Name and time row ///
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          commonText(
                                              height: 1.2,
                                              text:
                                              user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', fontWeight: FontWeight.bold),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0),
                                            child: commonText(
                                                height: 1.2,
                                                text: formatTime(messages.createdAt.toString()), color: Colors.grey, fontSize: 12
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            height: 30,
                                            child: PopupMenuButton<String>(
                                              color: AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : AppColor.appBarColor,
                                              offset: Offset(-20, 0),
                                              onSelected: (value) {
                                                chatProvider.pinUnPinMessage(receiverId: widget.oppositeUserId, messageId: messages.id ?? "", pinned: false,callForUnpinPostOnly: true);
                                              },
                                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                                PopupMenuItem<String>(
                                                  value: 'unpin',
                                                  height: 30,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(AppImage.pinTiltIcon,height: 20,width: 20,color: Colors.white,),
                                                      SizedBox(width: 10,),
                                                      commonText(text: 'Unpin from Channel',color: Colors.white),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              icon: Icon(Icons.more_vert),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    commonHTMLText(message: messages.content!),
                                    Visibility(
                                        visible: messages.isForwarded ?? false,
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
                                              commonText(text: "Forwarded",color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor,fontWeight: FontWeight.w500),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                child: Row(children: [
                                                  profileIconWithStatus(userID: messages.senderOfForwardSecondUser?.id ?? "", status: messages.senderOfForwardSecondUser?.status ?? "offline",needToShowIcon: false,otherUserProfile: messages.senderOfForwardSecondUser?.thumbnailAvatarUrl),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        commonText(text: "${messages.senderOfForwardSecondUser?.username}"),
                                                        SizedBox(height: 3),
                                                        commonText(text: formatDateString("${messages.senderOfForwardSecondUser?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                                      ],
                                                    ),
                                                  ),
                                                ],),
                                              ),
                                              commonHTMLText(message: "${messages.forwardMSGInfoSecondUser?.content}"),
                                              Visibility(
                                                visible: messages.forwardMSGInfoSecondUser?.files?.length != 0 ? true : false,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: messages.forwardMSGInfoSecondUser?.files?.length ?? 0,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    final filesUrl = messages.forwardMSGInfoSecondUser?.files?[index] ?? "";
                                                    String originalFileName = getFileName(messages.forwardMSGInfoSecondUser!.files?[index] ?? "");
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
                                      visible: messages.files?.length != 0,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: messages.files?.length ?? 0,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final filesUrl = messages.files![index];
                                          String originalFileName = getFileName(messages.files![index]);
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
                                      visible:messages.replyCount != 0,
                                      child: GestureDetector(
                                        onTap: () =>  pushReplacement(screen: ReplyMessageScreen(userName: user?.data?.user?.fullName ?? user?.data?.user?.username ?? 'Unknown', messageId: messages.id ?? "", receiverId: widget.oppositeUserId,),),
                                        child: Container(
                                          // color: Colors.red,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(right: 10),
                                                child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "",otherUserProfile: user?.data!.user!.thumbnailAvatarUrl ?? '',radius: 10,needToShowIcon: false),
                                              ),
                                              // 🖼️ Overlapping profile images
                                              // if (messageList.repliesSenderInfo != null && messageList.repliesSenderInfo!.isNotEmpty)
                                              //   Container(
                                              //     margin: EdgeInsets.only(right :messageList.repliesSenderInfo!.length > 1 ? 22 : 7),
                                              //     // color: Colors.amber,
                                              //     child: Row(
                                              //       children: [
                                              //         Stack(
                                              //           clipBehavior: Clip.none,
                                              //           children: [
                                              //             profileIconWithStatus(
                                              //               userID: messageList.repliesSenderInfo![0].id,
                                              //               status: "",
                                              //               needToShowIcon: false,
                                              //               radius: 12,
                                              //               otherUserProfile: messageList.repliesSenderInfo![0].avatarUrl,
                                              //             ),
                                              //             if (messageList.repliesSenderInfo!.length > 1)
                                              //               Positioned(
                                              //                 left: 16,
                                              //                 child: profileIconWithStatus(
                                              //                   userID: messageList.repliesSenderInfo![1].id,
                                              //                   status: "",
                                              //                   needToShowIcon: false,
                                              //                   radius: 12,
                                              //                   otherUserProfile: messageList.repliesSenderInfo![1].avatarUrl,
                                              //                 ),
                                              //               ),
                                              //           ],
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ),


                                              // 🔴 Red dot circle
                                              // Visibility(
                                              //   replacement: SizedBox.shrink(),
                                              //   visible: messageList.replies != null && messageList.replies!.isNotEmpty &&
                                              //       messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false),
                                              //   child: Container(
                                              //     margin:EdgeInsets.only(right: 5),
                                              //     width: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                              //     height: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                              //     decoration: const BoxDecoration(
                                              //       color: Colors.red,
                                              //       shape: BoxShape.circle,
                                              //     ),
                                              //   ),
                                              // ),

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
                                                text: "${messages.replyCount} ${messages.replyCount! > 1 ? 'replies' : 'reply'}",
                                                fontSize: 12,
                                                color: AppColor.borderColor,
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}



