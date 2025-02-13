import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/cubit/chat/chat_cubit.dart';
import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/model/message_model.dart';
import 'package:e_connect/providers/download_provider.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';

import '../../widgets/chat_profile_header.dart';
import '../../screens/chat/media_preview_screen.dart';

// class SingleChatMessageScreen extends StatefulWidget {
//   final String userName;
//   final String oppositeUserId;
//   final bool? calledForFavorite;
//   // final bool callForReadMsg;
//
//   const SingleChatMessageScreen(
//       {super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite});
//
//   @override
//   State<SingleChatMessageScreen> createState() =>
//       _SingleChatMessageScreenState();
// }
//
// class _SingleChatMessageScreenState extends State<SingleChatMessageScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final quill.QuillController _controller = quill.QuillController.basic();
//   final chatProvider1 = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
//   final commonProvider1 = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
//   final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
//   final FocusNode _focusNode = FocusNode();
//   String? lastSentMessage;
//   List<dynamic>? _lastSentDelta;
//   bool _showToolbar = false;
//   final Map<String, GetUserModel> userCache = {};
//   GetUserModel? userDetails;
//   @override
//   void initState() {
//     super.initState();
//     channelListProvider.addUserToChatList(selectedUserId: widget.oppositeUserId);
//     channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
//     chatProvider1.getMessagesList(widget.oppositeUserId);
//     _fetchAndCacheUserDetails();
//   }
//
//   void _fetchAndCacheUserDetails() async {
//     await commonProvider1.getUserByIDCall2(userId: widget.oppositeUserId);
//     userDetails = commonProvider1.getUserModel!;
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.black,
//       appBar: AppBar(
//         // backgroundColor: AppColor.appBarColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColor.whiteColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             userDetails != null
//                 ? commonText(
//               text: userDetails!.data!.user!.fullName ??
//                   userDetails!.data!.user!.username ??
//                   'Unknown',
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               // color: AppColor.whiteColor,
//             )
//                 : SizedBox(),
//             commonText(
//               text: 'View info >',
//               fontSize: 12,
//               // color: AppColor.whiteColor,
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
//             onPressed: () {
//               showChatSettingsBottomSheet(context);
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               controller: _scrollController,
//               child: Column(
//                 children: [
//                   userDetails != null
//                       ? ChatProfileHeader(
//                     userName: userDetails!.data!.user!.fullName ??
//                         userDetails!.data!.user!.username ??
//                         'Unknown',
//                     userImageUrl: ApiString.profileBaseUrl +
//                         (userDetails!.data!.user!.avatarUrl ?? ''),
//                   )
//                       : SizedBox(),
//                   Divider(
//                     color: Colors.grey.shade800,
//                     height: 1,
//                   ),
//                   dateHeaders()
//                 ],
//               ),
//             ),
//           ),
//
//           inputTextFieldWithEditor()
//         ],
//       ),
//     );
//   }
//
//   void _clearInputAndDismissKeyboard() {
//     _focusNode.unfocus();
//     _controller.clear();
//     setState(() {
//       _showToolbar = false;
//     });
//     // FocusScope.of(context).unfocus();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   Widget inputTextFieldWithEditor() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
//         border: Border(
//           top: BorderSide(
//             color: Colors.grey.shade800,
//             width: 0.5,
//           ),
//         ),
//       ),
//       child: Column(
//         children: [
//           if (_showToolbar)
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: quill.QuillToolbar.simple(
//                 configurations: quill.QuillSimpleToolbarConfigurations(
//                     controller: _controller,
//                     sharedConfigurations: const quill.QuillSharedConfigurations(
//                       locale: Locale('en'),
//                     ),
//                     showDividers: false,
//                     showFontFamily: false,
//                     showFontSize: false,
//                     showBoldButton: true,
//                     showItalicButton: true,
//                     showUnderLineButton: false,
//                     showStrikeThrough: true,
//                     showInlineCode: true,
//                     showColorButton: false,
//                     showBackgroundColorButton: false,
//                     showClearFormat: false,
//                     showAlignmentButtons: false,
//                     showLeftAlignment: false,
//                     showCenterAlignment: false,
//                     showRightAlignment: false,
//                     showJustifyAlignment: false,
//                     showHeaderStyle: true,
//                     showListNumbers: true,
//                     showListBullets: true,
//                     showListCheck: false,
//                     showCodeBlock: true,
//                     showQuote: true,
//                     showIndent: false,
//                     showLink: true,
//                     showUndo: false,
//                     showRedo: false,
//                     showSearchButton: false,
//                     showClipboardCut: false,
//                     showClipboardCopy: false,
//                     showClipboardPaste: false,
//                     multiRowsDisplay: false,
//                     showSubscript: false,
//                     showSuperscript: false),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: _showToolbar ? Colors.blue : AppColor.whiteColor,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _showToolbar = !_showToolbar;
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade900,
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: quill.QuillEditor(
//                         controller: _controller,
//                         focusNode: _focusNode,
//                         scrollController: ScrollController(),
//                         configurations: quill.QuillEditorConfigurations(
//                           scrollable: true,
//                           autoFocus: false,
//                           checkBoxReadOnly: false,
//                           placeholder: 'Write to Tosha Shah',
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           maxHeight: 100,
//                           minHeight: 40,
//                           customStyles: const quill.DefaultStyles(
//                             paragraph: quill.DefaultTextBlockStyle(
//                                 TextStyle(
//                                   color: AppColor.whiteColor,
//                                   fontSize: 16,
//                                 ),
//                                 quill.HorizontalSpacing.zero,
//                                 quill.VerticalSpacing.zero,
//                                 quill.VerticalSpacing.zero,
//                                 BoxDecoration(color: Colors.transparent)),
//                             placeHolder: quill.DefaultTextBlockStyle(
//                                 TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 16,
//                                 ),
//                                 quill.HorizontalSpacing.zero,
//                                 quill.VerticalSpacing.zero,
//                                 quill.VerticalSpacing.zero,
//                                 BoxDecoration(color: Colors.transparent)),
//                             quote: quill.DefaultTextBlockStyle(
//                               TextStyle(
//                                 color: AppColor.whiteColor,
//                                 fontSize: 16,
//                               ),
//                               quill.HorizontalSpacing(16, 0),
//                               quill.VerticalSpacing(8, 0),
//                               quill.VerticalSpacing(8, 0),
//                               BoxDecoration(
//                                 border: Border(
//                                   left: BorderSide(
//                                     color: AppColor.whiteColor,
//                                     width: 4,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           selectedFilesWidget(),
//           fileSelectionAndSendButtonRow()
//         ],
//       ),
//     );
//   }
//
//   // File selected to send
//   Widget selectedFilesWidget() {
//     return Consumer<FileServiceProvider>(
//       builder: (context, provider, _) {
//         return Visibility(
//           visible: provider.selectedFiles.isNotEmpty,
//           child: SizedBox(
//             height: 80,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: provider.selectedFiles.length,
//               itemBuilder: (context, index) {
//                 return Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => MediaPreviewScreen(
//                               files: provider.selectedFiles,
//                               initialIndex: index,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           width: 60,
//                           height: 60,
//                           color: AppColor.commonAppColor,
//                           child: getFileIcon(
//                             provider.selectedFiles[index].extension!,
//                             provider.selectedFiles[index].path,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: GestureDetector(
//                         onTap: () {
//                           provider.removeFile(index);
//                         },
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: AppColor.blackColor,
//                           child: CircleAvatar(
//                             radius: 10,
//                             backgroundColor: AppColor.borderColor,
//                             child: Icon(
//                               Icons.close,
//                               color: AppColor.blackColor,
//                               size: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void showCameraOptionsBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColor.appBarColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               commonText(
//                 text: 'Camera Options',
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: AppColor.whiteColor,
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading:
//                 const Icon(Icons.camera_alt, color: AppColor.whiteColor),
//                 title: commonText(
//                   text: 'Capture Photo',
//                   color: AppColor.whiteColor,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   FileServiceProvider.instance.captureMedia(isVideo: false);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.videocam, color: AppColor.whiteColor),
//                 title: commonText(
//                   text: 'Record Video',
//                   color: AppColor.whiteColor,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   FileServiceProvider.instance.captureMedia(isVideo: true);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget fileSelectionAndSendButtonRow() {
//     return Container(
//       padding: const EdgeInsets.only(
//         left: 8,
//         right: 8,
//         bottom: 8,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.alternate_email, color: AppColor.whiteColor),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.attach_file, color: AppColor.whiteColor),
//             onPressed: () {
//               FileServiceProvider.instance.pickFiles();
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.image, color: AppColor.whiteColor),
//             onPressed: () {
//               FileServiceProvider.instance.pickImages();
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.camera_alt, color: AppColor.whiteColor),
//             onPressed: () {
//               showCameraOptionsBottomSheet(context);
//             },
//           ),
//           GestureDetector(
//             onTap: () {
//               final plainText = _controller.document.toPlainText().trim();
//               if (plainText.isNotEmpty) {
//                 setState(() {
//                   lastSentMessage = plainText;
//                   _lastSentDelta = _controller.document.toDelta().toJson();
//                 });
//                 chatProvider1.sendMessage(content: _controller.document.toDelta().toJson(), receiverId: widget.oppositeUserId, senderId: signInModel.data!.user?.id ?? "");
//                 _clearInputAndDismissKeyboard();
//               }
//             },
//             child: Container(
//                 decoration: BoxDecoration(
//                     color: AppColor.lightBlueColor,
//                     borderRadius: BorderRadius.circular(10)),
//                 child: Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
//                   child: Icon(Icons.send, color: AppColor.whiteColor),
//                 )),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget dateHeaders() {
//     return Consumer<ChatProvider>(builder: (context, value, child) {
//       List<MessageGroups> sortedGroups = value.messageGroups
//         ..sort((a, b) => b.sId!.compareTo(a.sId!));
//       return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
//         shrinkWrap: true,
//         reverse: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemCount: sortedGroups.length,
//         itemBuilder: (context, index) {
//           final group = sortedGroups[index];
//           List<Messages> sortedMessages = (group.messages ?? [])
//             ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
//           String? previousSenderId;
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColor.appBarColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: commonText(
//                     text: formatDateTime(DateTime.parse(group.sId!)),
//                     fontSize: 12,
//                     color: AppColor.whiteColor,
//                   ),
//                 ),
//               ),
//               ...sortedMessages.map((Messages message) {
//                 bool showUserDetails = previousSenderId != message.senderId;
//                 previousSenderId = message.senderId;
//                 return chatBubble(
//                   userId: message.senderId!,
//                   message: message.content!,
//                   time: DateTime.parse(message.createdAt!).toString(),
//                   showUserDetails: showUserDetails,
//                 );
//               }).toList(),
//             ],
//           );
//         },
//       );
//     },);
//   }
//
//   String formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(Duration(days: 1));
//     final aWeekAgo = today.subtract(Duration(days: 7));
//
//     if (dateTime.isAfter(today)) {
//       return 'Today';
//     } else if (dateTime.isAfter(yesterday)) {
//       return 'Yesterday';
//     } else if (dateTime.isAfter(aWeekAgo)) {
//       return DateFormat('EEEE').format(dateTime); // Day of the week
//     } else {
//       return DateFormat('MM-dd-yyyy').format(dateTime); // MM-dd-yyyy format
//     }
//   }
//
//   String formatTime(DateTime dateTime) {
//     return DateFormat('hh:mm a').format(dateTime); // hh:mm AM/PM format
//   }
//
//   Widget chatBubble({
//     required String userId,
//     required String message,
//     required String time,
//     bool showUserDetails = true,
//   }) {
//     if (!userCache.containsKey(userId)) {
//       commonProvider1.getUserByIDCall2(userId: userId);
//     }
//
//     return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
//       if (commonProvider.getUserModel!.data!.user!.sId! == userId) {
//         userCache[userId] = commonProvider.getUserModel!;
//       }
//       final user = userCache[userId];
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             if (showUserDetails) ...{
//               SizedBox(
//                 width: 40,
//                 child: CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(
//                     ApiString.profileBaseUrl +
//                         (user?.data!.user!.avatarUrl ?? ''),
//                   ),
//                 ),
//               ),
//             } else ...{
//               SizedBox(width: 50)
//             },
//             if (showUserDetails) SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (showUserDetails)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           user?.data!.user!.fullName ??
//                               user?.data!.user!.username ??
//                               'Unknown',
//                           style: TextStyle(
//                             // color: Colors.white,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(width: 5),
//                         Text(
//                           formatTime(DateTime.parse(time)),
//                           style: TextStyle(color: Colors.grey, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   HtmlWidget(
//                     message,
//                     textStyle: TextStyle( fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//     );
//   }
// }

/// ///


class SingleChatMessageScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  final bool? calledForFavorite;
  final bool? needToCallAddMessage;
  // final bool callForReadMsg;

  const SingleChatMessageScreen(
      {super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite, this.needToCallAddMessage});

  @override
  State<SingleChatMessageScreen> createState() =>
      _SingleChatMessageScreenState();
}

class _SingleChatMessageScreenState extends State<SingleChatMessageScreen> {
  final ScrollController _scrollController = ScrollController();
  final quill.QuillController _controller = quill.QuillController.basic();
  final chatProvider1 = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
  final commonProvider1 = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  final FocusNode _focusNode = FocusNode();
  String? lastSentMessage;
  List<dynamic>? _lastSentDelta;
  bool _showToolbar = false;
  final Map<String, GetUserModel> userCache = {};
  GetUserModel? userDetails;
  @override
  void initState() {
    super.initState();
    if(widget.needToCallAddMessage == true){
      channelListProvider.addUserToChatList(selectedUserId: widget.oppositeUserId);
    }
    channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
    chatProvider1.getMessagesList(widget.oppositeUserId);
    _fetchAndCacheUserDetails();
  }

  void _fetchAndCacheUserDetails() async {
    await commonProvider1.getUserByIDCall2(userId: widget.oppositeUserId);
    userDetails = commonProvider1.getUserModel!;
    print("user>>>>>> ${userDetails?.data!.user!.username}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.whiteColor),
            onPressed: () =>pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userDetails != null ? commonText(
                text: userDetails!.data!.user!.fullName ?? userDetails!.data!.user!.username ?? 'Unknown',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                // color: AppColor.whiteColor,
              ) : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(children: [
                  getCommonStatusIcons(
                    size: 15,
                    status: "${commonProvider.getUserModel?.data?.user!.status!}",
                    assetIcon: false,
                  ),
                  SizedBox(width: 5,),
                  commonText(text: capitalizeFirstLetter("${commonProvider.getUserModel?.data?.user!.status!}"),height: 1 ,fontWeight: FontWeight.w400,fontSize: 15)
                ],),
              )
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
              onPressed: () {
                // isMutedUser: signInModel.data?.user!.muteUsers!.contains(widget.oppositeUserId) ?? false != true,
                showChatSettingsBottomSheet(userId: widget.oppositeUserId);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // userDetails != null
            //     ? ChatProfileHeader(
            //   userName: userDetails!.data!.user!.fullName ??
            //       userDetails!.data!.user!.username ??
            //       'Unknown',
            //   userImageUrl: ApiString.profileBaseUrl +
            //       (userDetails!.data!.user!.avatarUrl ?? ''),
            // )
            //     : SizedBox(),
            Divider(
              color: Colors.grey.shade800,
              height: 1,
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                reverse: true,
                children: [
                  dateHeaders(),
                ],
              ),
            ),
            inputTextFieldWithEditor()
          ],
        ),
      );
    },);
  }

  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _showToolbar = false;
    });
    // FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
                          placeholder: 'Write to Tosha Shah',
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

  // File selected to send
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
            onTap: () {
              // print("filesss ${fileServiceProvider.selectedFiles}");
              final plainText = _controller.document.toPlainText().trim();
              if (plainText.isNotEmpty) {
                setState(() {
                  lastSentMessage = plainText;
                  _lastSentDelta = _controller.document.toDelta().toJson();
                });
                chatProvider1.sendMessage(content: _controller.document.toDelta().toJson(), receiverId: widget.oppositeUserId, senderId: signInModel.data!.user?.id ?? "",selectedFiles: fileServiceProvider.selectedFiles);
                _clearInputAndDismissKeyboard();
              }else {
                chatProvider1.sendMessage(content: "", receiverId: widget.oppositeUserId, senderId: signInModel.data!.user?.id ?? "",selectedFiles: fileServiceProvider.selectedFiles);
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

  Widget dateHeaders() {
    return Consumer<ChatProvider>(builder: (context, value, child) {
      List<MessageGroups> sortedGroups = value.messageGroups
        ..sort((a, b) => b.sId!.compareTo(a.sId!));
      return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedGroups.length,
        itemBuilder: (context, index) {
          final group = sortedGroups[index];
          List<Messages> sortedMessages = (group.messages ?? [])..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
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
                        text: formatDateTime(DateTime.parse(group.sId!)),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ...sortedMessages.map((Messages message) {
                bool showUserDetails = previousSenderId != message.senderId;
                previousSenderId = message.senderId;
                return chatBubble(
                  messageList: message,
                  userId: message.senderId!,
                  message: message.content!,
                  time: DateTime.parse(message.createdAt!).toString(),
                  showUserDetails: showUserDetails,
                );
              }).toList(),
            ],
          );
        },
      );
    },);
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

  Widget chatBubble({
    required Messages messageList,
    required String userId,
    required String message,
    required String time,
    bool showUserDetails = true,
  }) {
    if (!userCache.containsKey(userId)) {
      commonProvider1.getUserByIDCall2(userId: userId);
    }

    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      if (commonProvider.getUserModel!.data!.user!.sId! == userId) {
        userCache[userId] = commonProvider.getUserModel!;
      }
      final user = userCache[userId];
      final pinnedMsg = messageList.isPinned ?? false;
      return Container(
        color:  pinnedMsg == true ? AppPreferenceConstants.themeModeBoolValueGet ? AppColor.pinnedColorDark : AppColor.pinnedColorLight : null,
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
                   child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "${user?.data!.user!.status}",otherUserProfile: user?.data!.user!.avatarUrl ?? '',),
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
                              user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', fontWeight: FontWeight.bold),
                            SizedBox(width: 2.5),
                            if (signInModel.data?.user!.id == user?.data!.user!.sId && commonProvider.customStatusUrl.isNotEmpty) ...{
                                CachedNetworkImage(
                                    width: 20,
                                    height: 20,
                                    imageUrl: commonProvider.customStatusUrl,
                                  ),
                              } else if (userDetails?.data!.user!.customStatusEmoji != "" && userDetails?.data!.user!.customStatusEmoji != null) ...{
                              CachedNetworkImage(
                                    width: 20,
                                    height: 20,
                                    imageUrl: userDetails?.data!.user!.customStatusEmoji,
                                  ),
                              },
                              SizedBox(width: 2.5),
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
                                commonText(text: formattedFileName,maxLines: 1),
                                Spacer(),
                                GestureDetector(
                                    onTap: () => Provider.of<DownloadFileProvider>(context,listen: false).downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
                                    child: Image.asset(AppImage.downloadIcon,fit: BoxFit.contain,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))
                              ],
                            ),
                          );
                        },),
                      )
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
}
