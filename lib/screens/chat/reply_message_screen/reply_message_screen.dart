import 'package:e_connect/model/get_reply_message_model.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../providers/channel_list_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/common_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/file_service_provider.dart';
import '../../../socket_io/socket_io.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../forward_message/forward_message_screen.dart';
import '../media_preview_screen.dart';


class ReplyMessageScreen extends StatefulWidget {
  final String userName;
  String messageId;
  final String receiverId;

   ReplyMessageScreen({super.key, required this.userName, required this.messageId, required this.receiverId,});

  @override
  State<ReplyMessageScreen> createState() => _ReplyMessageScreenState();
}

class _ReplyMessageScreenState extends State<ReplyMessageScreen> {
  final scrollController = ScrollController();
  bool _showToolbar = false;
  final quill.QuillController _controller = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final chatProvider = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  String currentUserMessageId = "";
  int? _selectedIndex;

  @override
  void initState() {
    print("msgIDD>>>> ${widget.messageId}");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    chatProvider.getReplyListUpdateSC(widget.messageId);
    socketProvider.socketListenPinMessageInReplyScreen(msgId: widget.messageId);
    print("I'm In initState");
    Provider.of<ChatProvider>(context, listen: false).getReplyMessageList(msgId: widget.messageId,fromWhere: "SCREEN INIT");
    Provider.of<ChatProvider>(context, listen: false).seenReplayMessage(msgId: widget.messageId);
  });
}

@override
  void dispose() {
  Provider.of<ChatProvider>(context, listen: false).disposeReplyMSG();
  super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          // setState(() {
            // widget.messageId = "";
          // });
          pop(popValue: true);
        },
        icon: Icon(CupertinoIcons.back,color: Colors.white,)),
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
          inputTextFieldWithEditor(),
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
                  previousSenderId = message?.senderId!.sId;
                  return chatBubble(
                    chatIndex: index, // Pass index here
                    messageList: message!,
                    messageId: messageList?.groupMessages?[index].sId ?? "",
                    userId: message.senderId?.sId ?? "",
                    message: message.content ?? "",
                    time: DateTime.parse(message.createdAt!).toString(),
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
    required int chatIndex,
    required GroupMessages messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
  })  {
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      bool pinnedMsg = messageList.isPinned ?? false;
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
                  /// Profile  Section ///
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: profileIconWithStatus(userID: "${messageList.senderId!.sId}", status: "${messageList.senderId!.status}",otherUserProfile: "${messageList.senderId!.avatarUrl}",radius: 17),
                  ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            commonText(
                                height: 1.2,
                                text:
                                messageList.senderId?.userName ?? messageList.senderId!.fullName ?? 'Unknown', fontWeight: FontWeight.bold),
                            SizedBox(width: 5),
                            commonText(
                                height: 1.2,
                                text: formatTime(time), color: Colors.grey, fontSize: 12
                            ),
                          ],
                        ),
                      commonHTMLText(message: message),
                      Visibility(
                          visible: messageList.isForwarded ?? false,
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
                                    profileIconWithStatus(userID: messageList.forwardFrom?.sId ?? "", status: messageList.forwardFrom?.senderId?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.forwardFrom?.senderId?.avatarUrl),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          commonText(text: messageList.forwardFrom?.senderId?.userName ?? messageList.forwardFrom?.senderId?.fullName ?? ""),
                                          SizedBox(height: 3),
                                          commonText(text: formatDateString("${messageList.forwardFrom?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                commonHTMLText(message: "${messageList.forwardFrom?.content}"),
                                Visibility(
                                  visible: messageList.forwardFrom?.files?.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwardFrom?.files?.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwardFrom?.files?[index];
                                      String originalFileName = getFileName(messageList.forwardFrom?.files?[index]);
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
                      // Spacer(),
                    ],
                  ),
                ),
                popMenuForReply2(context,
                  isPinned: pinnedMsg,
                  onOpened: () =>  setState(() => _selectedIndex = chatIndex),
                  onClosed: () =>  setState(() => _selectedIndex = null),
                  opened: chatIndex == _selectedIndex ? true : false,
                  currentUserId: messageList.senderId?.sId ?? "",
                  onForward: () => pushScreen(screen: ForwardMessageScreen(userName: messageList.senderId?.userName ?? messageList.senderId!.fullName ?? 'Unknown',time: formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: "${messageList.senderId!.avatarUrl}",forwardMsgId: messageId,)),
                  onPin: () => chatProvider.pinUnPinMessageForReply(receiverId: widget.receiverId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg ),
                  onCopy: () => copyToClipboard(context, message),
                  onEdit: () => setState(() {
                    int position = _controller.document.length - 1;
                    currentUserMessageId = messageId;
                    print("currentMessageId>>>>> $currentUserMessageId && 67b6d585d75f40cdb09398f5");
                    _controller.document.insert(position, message.toString());
                    _controller.updateSelection(
                      TextSelection.collapsed(offset: _controller.document.length),
                      quill.ChangeSource.local,
                    );
                  }),
                  onDelete: () {
                    chatProvider.deleteMessageForReply(messageId: messageId.toString(),firsMessageId: widget.messageId,userName: widget.userName,oppId: widget.receiverId);
                  },
                  createdAt:"${messageList.createdAt}",)
              ],
            ),
          ],
        ),
      );
    },
    );
  }

  Widget inputTextFieldWithEditor() {
    return Container(
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade800,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_showToolbar)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    sharedConfigurations: const quill.QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                    showDividers: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: false,
                    showStrikeThrough: true,
                    showInlineCode: true,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showHeaderStyle: true,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: false,
                    showCodeBlock: true,
                    showQuote: true,
                    showIndent: false,
                    showLink: true,
                    showUndo: false,
                    showRedo: false,
                    showSearchButton: false,
                    showClipboardCut: false,
                    showClipboardCopy: false,
                    showClipboardPaste: false,
                    multiRowsDisplay: false,
                    showSubscript: false,
                    showSuperscript: false),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: _showToolbar ? Colors.blue : AppColor.whiteColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showToolbar = !_showToolbar;
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: quill.QuillEditor(
                        controller: _controller,
                        focusNode: _focusNode,
                        scrollController: ScrollController(),
                        configurations: quill.QuillEditorConfigurations(
                          scrollable: true,
                          autoFocus: false,
                          checkBoxReadOnly: false,
                          placeholder: 'Write to ${widget.userName}',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          maxHeight: 100,
                          minHeight: 40,
                          customStyles: const quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 16,
                                ),
                                quill.HorizontalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                BoxDecoration(color: Colors.transparent)),
                            placeHolder: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                quill.HorizontalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                BoxDecoration(color: Colors.transparent)),
                            quote: quill.DefaultTextBlockStyle(
                              TextStyle(
                                color: AppColor.whiteColor,
                                fontSize: 16,
                              ),
                              quill.HorizontalSpacing(16, 0),
                              quill.VerticalSpacing(8, 0),
                              quill.VerticalSpacing(8, 0),
                              BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: AppColor.whiteColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          selectedFilesWidget(),
          fileSelectionAndSendButtonRow()
        ],
      ),
    );
  }
  Widget selectedFilesWidget() {
    return Consumer<FileServiceProvider>(
      builder: (context, provider, _) {
        return Visibility(
          visible: provider.selectedFiles.isNotEmpty,
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.selectedFiles.length,
              itemBuilder: (context, index) {
                print("FILES>>>> ${provider.selectedFiles[index].path}");
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaPreviewScreen(
                              files: provider.selectedFiles,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColor.commonAppColor,
                          child: getFileIcon(
                            provider.selectedFiles[index].extension!,
                            provider.selectedFiles[index].path,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          provider.removeFile(index);
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColor.blackColor,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColor.borderColor,
                            child: Icon(
                              Icons.close,
                              color: AppColor.blackColor,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
  Widget fileSelectionAndSendButtonRow() {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.alternate_email, color: AppColor.whiteColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColor.whiteColor),
            onPressed: () {
              FileServiceProvider.instance.pickFiles();
            },
          ),
          IconButton(
            icon: const Icon(Icons.image, color: AppColor.whiteColor),
            onPressed: () {
              FileServiceProvider.instance.pickImages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColor.whiteColor),
            onPressed: () {
              showCameraOptionsBottomSheet(context);
            },
          ),
          GestureDetector(
            onTap: () async {
              final plainText = _controller.document.toPlainText().trim();
              if(fileServiceProvider.selectedFiles.isNotEmpty){
                final filesOfList = await chatProvider.uploadFiles();
                chatProvider.sendMessage(content: plainText, receiverId: widget.receiverId,files: filesOfList,replyId: widget.messageId);
                _clearInputAndDismissKeyboard();
              }else{
                chatProvider.sendMessage(content: plainText, receiverId: widget.receiverId,replyId: widget.messageId,editMsgID: currentUserMessageId.isEmpty ? "" : currentUserMessageId).then((value) => setState(() {
                  currentUserMessageId = "";
                }),);
                _clearInputAndDismissKeyboard();
              }
            },
            child: Container(
                decoration: BoxDecoration(
                    color: AppColor.lightBlueColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                  child: Icon(Icons.send, color: AppColor.whiteColor),
                )),
          ),
        ],
      ),
    );
  }
  void showCameraOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              commonText(
                text: 'Camera Options',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.whiteColor,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading:
                const Icon(Icons.camera_alt, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Capture Photo',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Record Video',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _showToolbar = false;
    });
    FocusScope.of(context).unfocus();
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

}
