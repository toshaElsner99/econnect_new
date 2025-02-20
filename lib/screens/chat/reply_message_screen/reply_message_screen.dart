import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/cubit/chat/chat_cubit.dart';
import 'package:e_connect/model/get_reply_message_model.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../cubit/common_cubit/common_cubit.dart';
import '../../../model/message_model.dart';
import '../../../providers/download_provider.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';

class ReplyMessageScreen extends StatefulWidget {
  final String userName;
  final String messageId;

  const ReplyMessageScreen(
      {super.key, required this.userName, required this.messageId});

  @override
  State<ReplyMessageScreen> createState() => _ReplyMessageScreenState();
}

class _ReplyMessageScreenState extends State<ReplyMessageScreen> {
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).getReplyMessageList(msgId: widget.messageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => pop(), icon: Icon(CupertinoIcons.back)),
        bottom: PreferredSize(preferredSize: Size.zero , child: Divider(color: Colors.grey.shade800, height: 1,),),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(text: "Thread", fontSize: 16,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: commonText(text: widget.userName, fontSize: 12,fontWeight: FontWeight.w400),

            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              reverse: true,
              children: [
                dateHeaders(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dateHeaders() {
    return Consumer<ChatProvider>(builder: (context, value, child) {
      return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: false,
        physics: NeverScrollableScrollPhysics(),
        itemCount: value.getReplyMessageModel?.data?.messages?.length ?? 0,
        itemBuilder: (itemContext, index) {
          final messageList =  value.getReplyMessageModel?.data?.messages?[index];
          final grpId = messageList?.date;
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
                        text: formatDateTime(DateTime.parse(grpId!)),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: messageList?.groupMessages?.length ?? 0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  GroupMessages? message = messageList?.groupMessages?[index];
                  bool showUserDetails = previousSenderId != message!.senderId!.sId;
                  previousSenderId = message!.senderId!.sId;
                  return chatBubble(
                    index: index, // Pass index here
                    messageList: message,
                    messageId: messageList?.groupMessages?[index].sId ?? "",
                    userId: message.senderId?.sId ?? "",
                    message: message.content ?? "",
                    time: DateTime.parse(message.createdAt!).toString(),
                    showUserDetails: showUserDetails,
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
    required GroupMessages messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
    bool showUserDetails = true,
  })  {

    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      final pinnedMsg = messageList.isPinned ?? false;
      return Container(
        color:  pinnedMsg == true ? AppPreferenceConstants.themeModeBoolValueGet ? Colors.greenAccent.withOpacity(0.15) : AppColor.pinnedColorLight : null,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Column(
          children: [
            Visibility(
                visible: pinnedMsg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(AppImage.pinMessageIcon,height: 12,width: 12,),
                      SizedBox(width: 5,),
                      commonText(text: "Pinned",color: AppColor.blueColor)
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
                    child: profileIconWithStatus(userID: "${messageList.senderId!.sId}", status: "${messageList.senderId!.status}",otherUserProfile: "${messageList.senderId!.avatarUrl}",radius: 17),
                  )
                } else ...{
                  SizedBox(width: 45)
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
                            commonText(
                                height: 1.2,
                                text:
                                messageList.senderId!.username ?? messageList.senderId!.fullName ?? 'Unknown', fontWeight: FontWeight.bold),
                            SizedBox(width: 5),
                            commonText(
                                height: 1.2,
                                text: formatTime(DateTime.parse(time)), color: Colors.grey, fontSize: 12
                            ),
                          ],
                        ),
                      HtmlWidget(
                        message,
                        enableCaching: true,
                        textStyle: TextStyle( fontSize: 16),
                      ),
                      Visibility(
                        visible: messageList.isMedia == true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files?.length ?? 0,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files![index];
                            String originalFileName = getFileName(messageList.files![index]);
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
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
    );
  }
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateTime.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // hh:mm AM/PM format
  }

}
