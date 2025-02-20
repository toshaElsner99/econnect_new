// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:e_connect/providers/download_provider.dart';
// import 'package:e_connect/providers/file_service_provider.dart';
// import 'package:e_connect/socket_io/socket_io.dart';
// import 'package:e_connect/utils/api_service/api_string_constants.dart';
// import 'package:e_connect/utils/app_color_constants.dart';
// import 'package:e_connect/utils/app_image_assets.dart';
// import 'package:e_connect/utils/app_preference_constants.dart';
// import 'package:e_connect/utils/common/common_function.dart';
// import 'package:e_connect/utils/common/common_widgets.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import 'cubit/channel_list/channel_list_cubit.dart';
// import 'cubit/chat/chat_cubit.dart';
// import 'cubit/common_cubit/common_cubit.dart';
// import 'main.dart';
// import 'model/get_user_model.dart';
// import 'model/message_model.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String userName;
//   final String oppositeUserId;
//   final bool? calledForFavorite;
//   final bool? needToCallAddMessage;
//   const ChatScreen({super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite, this.needToCallAddMessage});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final chatProvider = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
//   final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
//   final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
//   final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
//   final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
//
//   final _scrollController = ScrollController();
//
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       commonProvider.getUserByIDCall();
//       commonProvider.getUserByIDCallForSecondUser(userId: widget.oppositeUserId);
//       chatProvider.getMessagesList(widget.oppositeUserId);
//       socketProvider.listenSingleChatScreen(oppositeUserId: widget.oppositeUserId);
//       chatProvider.getTypingUpdate();
//       commonProvider.updateStatusCall(status: "online");
//
//       /// Other & Latter Functionality ///
//       if(widget.needToCallAddMessage == true){
//         channelListProvider.addUserToChatList(selectedUserId: widget.oppositeUserId);
//       }
//       channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
//     });
//
//     // _controller.addListener(() {
//     //   socketProvider.userTypingEvent(oppositeUserId: widget.oppositeUserId, isReplyMsg: false, isTyping: _controller.document.toPlainText().trim().length > 1 ? 1 : 0);
//     // },);
//
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<CommonProvider,ChatProvider>(builder: (context, commonProvider,chatProvider, child) {
//       return Scaffold(
//         appBar: _buildAppBar(commonProvider, chatProvider),
//         body: Column(children: [
//           Divider(color: Colors.grey, height: 1,),
//           Expanded(
//             child: ListView(
//               controller: _scrollController,
//               reverse: true,
//               children: [
//                 dateHeaders(),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
//             decoration: BoxDecoration(
//               border: Border.all(color: AppColor.borderColor,),
//             ),
//               child: commonTextFormField(controller: TextEditingController(), hintText: "Type"),
//           ),
//         ],),
//       );
//     },);
//   }
//   Widget dateHeaders() {
//     return Consumer<ChatProvider>(builder: (context, value, child) {
//       List<MessageGroups> sortedGroups = value.messageGroups..sort((a, b) => b.sId!.compareTo(a.sId!));
//       return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
//         shrinkWrap: true,
//         reverse: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemCount: sortedGroups.length,
//         itemBuilder: (itemContext, index) {
//           final group = sortedGroups[index];
//           List<Messages> sortedMessages = (group.messages ?? [])..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
//           String? previousSenderId;
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Container(
//                       margin: const EdgeInsets.symmetric(vertical: 10),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: AppColor.blueColor,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: commonText(
//                         text: formatDateTime(DateTime.parse(group.sId!)),
//                         fontSize: 12,
//                         color: AppColor.whiteColor,
//                       ),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//               ),
//               ListView.builder(
//                 itemCount: sortedMessages.length,
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   Messages message = sortedMessages[index]; // Get message data
//                   bool showUserDetails = (index == 0 || sortedMessages[index - 1].senderId != message.senderId);
//
//                   // if (commonProvider.getUserModel?.data?.user?.sId != message.senderId) {
//                   //   chatProvider.userCache[message.senderId.toString()] = commonProvider.getUserModelSecondUser!;
//                   // }
//                   return chatBubble(
//                     index: index, // Pass index here
//                     messageList: message,
//                     userId: message.senderId!,
//                     message: message.content!,
//                     time: DateTime.parse(message.createdAt!).toString(),
//                     showUserDetails: showUserDetails,
//                   );
//                 },
//               )
//               // ...sortedMessages.asMap().entries.map((entry) {
//               //   int index = entry.key; // Get index
//               //   Messages message = entry.value; // Get message data
//               //
//               //   bool showUserDetails = previousSenderId != message.senderId;
//               //   previousSenderId = message.senderId;
//               //
//               //   return chatBubble(
//               //     index: index, // Pass index here
//               //     messageList: message,
//               //     userId: message.senderId!,
//               //     message: message.content!,
//               //     time: DateTime.parse(message.createdAt!).toString(),
//               //     showUserDetails: showUserDetails,
//               //   );
//               // }).toList()
//
//               // ...sortedMessages.map((Messages message) {
//               //   bool showUserDetails = previousSenderId != message.senderId;
//               //   previousSenderId = message.senderId;
//               //   return chatBubble(
//               //     index: index,
//               //     messageList: message,
//               //     userId: message.senderId!,
//               //     message: message.content!,
//               //     time: DateTime.parse(message.createdAt!).toString(),
//               //     showUserDetails: showUserDetails,
//               //   );
//               // }).toList(),
//             ],
//           );
//         },
//       );
//     },);
//   }
//   Widget chatBubble({
//     required int index,
//     required Messages messageList,
//     required String userId,
//     required String message,
//     required String time,
//     bool showUserDetails = true,
//   }) {
//     if (!chatProvider.userCache.containsKey(userId)) {
//       // commonProvider.getUserByIDCall2(userId: message.senderId);
//       if (commonProvider.getUserModel?.data?.user?.sId != userId) {
//         setState(() {
//           chatProvider.userCache[userId] = commonProvider.getUserModelSecondUser!;
//         });
//       }
//     }
//     return Consumer2<CommonProvider,ChatProvider>(builder: (context, commonProvider,chatProvider, child) {
//       final user = chatProvider.userCache[userId];
//       final pinnedMsg = messageList.isPinned ?? false;
//       return Container(
//         color:  pinnedMsg == true ? AppPreferenceConstants.themeModeBoolValueGet ? Colors.greenAccent.withOpacity(0.15) : AppColor.pinnedColorLight : null,
//         padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
//         child: Column(
//           children: [
//             Visibility(
//                 visible: pinnedMsg,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 5),
//                   child: Row(
//                     children: [
//                       Image.asset(AppImage.pinMessageIcon,height: 12,width: 12,),
//                       SizedBox(width: 5,),
//                       commonText(text: "Pinned",color: AppColor.blueColor)
//                     ],
//                   ),
//                 )),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 if (showUserDetails) ...{
//                   /// Profile  Section ///
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 2.5),
//                     child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "${user?.data!.user!.status}",otherUserProfile: user?.data!.user!.avatarUrl ?? '',),
//                   )
//                 } else ...{
//                   SizedBox(width: 45)
//                 },
//                 if (showUserDetails) SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (showUserDetails)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             commonText(
//                                 height: 1.2,
//                                 text:
//                                 user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', fontWeight: FontWeight.bold),
//                             SizedBox(width: 2.5),
//                             if (signInModel.data?.user!.id == user?.data!.user!.sId && commonProvider.customStatusUrl.isNotEmpty) ...{
//                               CachedNetworkImage(
//                                 width: 20,
//                                 height: 20,
//                                 imageUrl: commonProvider.customStatusUrl,
//                               ),
//                             } else if (commonProvider.getUserModel?.data!.user!.customStatusEmoji != "" && commonProvider.getUserModel?.data!.user!.customStatusEmoji != null) ...{
//                               CachedNetworkImage(
//                                 width: 20,
//                                 height: 20,
//                                 imageUrl: commonProvider.getUserModel?.data!.user!.customStatusEmoji,
//                               ),
//                             },
//                             SizedBox(width: 2.5),
//                             commonText(
//                                 height: 1.2,
//                                 text: formatTime(DateTime.parse(time)), color: Colors.grey, fontSize: 12
//                             ),
//                           ],
//                         ),
//                       HtmlWidget(
//                         message,
//                         enableCaching: true,
//                         textStyle: TextStyle( fontSize: 16),
//                       ),
//                       Visibility(
//                         visible: messageList.isMedia == true,
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: messageList.files?.length ?? 0,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             final filesUrl = messageList.files![index];
//                             String originalFileName = getFileName(messageList.files![index]);
//                             String formattedFileName = formatFileName(originalFileName);
//                             String fileType = getFileExtension(originalFileName);
//                             // IconData fileIcon = getFileIcon(fileType);
//                             return Container(
//                               margin: EdgeInsets.only(top: 4,right: 10),
//                               padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: AppColor.lightGreyColor),
//                               ),
//                               child: Row(
//                                 children: [
//                                   getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
//                                   SizedBox(width: 20,),
//                                   commonText(text: formattedFileName,maxLines: 1),
//                                   Spacer(),
//                                   GestureDetector(
//                                       onTap: () => Provider.of<DownloadFileProvider>(context,listen: false).downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
//                                       child: Image.asset(AppImage.downloadIcon,fit: BoxFit.contain,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))
//                                 ],
//                               ),
//                             );
//                           },),
//                       )
//                     ],
//                   ),
//                 ),
//                 // Builder(
//                 //   builder: (itemContext) => GestureDetector(
//                 //     onTapDown: (details) => _storePosition(details, itemContext,index), // Capture tap position correctly
//                 //     onTap: () => _showPopup(context), // Show the pop-up menu
//                 //     child: Container(
//                 //         width: 20,
//                 //         height: 23,
//                 //         margin: EdgeInsets.only(right: 16),
//                 //         child: Icon(Icons.more_vert, color: index == _selectedIndex ? AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black : Colors.grey, size: 30)),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//     );
//   }
//
//
//   String formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(Duration(days: 1));
//
//     if (dateTime.isAtSameMomentAs(today)) {
//       return 'Today';
//     } else if (dateTime.isAtSameMomentAs(yesterday)) {
//       return 'Yesterday';
//     } else {
//       return DateFormat('yyyy-MM-dd').format(dateTime);
//     }
//   }
//   String formatTime(DateTime dateTime) {
//     return DateFormat('hh:mm a').format(dateTime); // hh:mm AM/PM format
//   }
//
//   AppBar _buildAppBar(CommonProvider commonProvider, ChatProvider chatProvider) {
//     return AppBar(
//         toolbarHeight: 60,
//         leadingWidth: 35,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 15.0),
//           child: IconButton(icon: Icon(CupertinoIcons.back,color: Colors.white,),color: Colors.white, onPressed: () => pop(),),
//         ),
//         titleSpacing: 20,
//         title:  Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 commonText(
//                     text: widget.userName,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                     maxLines: 1
//                 ),
//                 Visibility(
//                   visible: commonProvider.getUserModelSecondUser?.data?.user?.isFavourite ?? false,
//                   child: Icon(Icons.star_rate_rounded),),
//               ],
//             ) ,
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Row(
//                 children: [
//                   getCommonStatusIcons(
//                     size: 15,
//                     status: commonProvider.getUserModelSecondUser?.data?.user?.status ?? "offline",
//                     assetIcon: false,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 5.0,right: 5.0),
//                     child: (commonProvider.getUserModelSecondUser?.data!.user!.sId  == chatProvider.oppUserIdForTyping && chatProvider.msgLength == 1) ? commonText(text: "Typing...",height: 1 ,fontWeight: FontWeight.w400,fontSize: 15,maxLines: 1) : commonText(text: getLastOnlineStatus(commonProvider.getUserModelSecondUser?.data?.user?.status ?? ".....", commonProvider.getUserModelSecondUser?.data?.user!.lastActiveTime),height: 1 ,fontWeight: FontWeight.w400,fontSize: 15,maxLines: 1),
//                   ),
//                   Visibility(
//                     visible: commonProvider.getUserModelSecondUser?.data?.user!.customStatusEmoji != null && commonProvider.getUserModelSecondUser?.data?.user!.customStatusEmoji!.isNotEmpty,
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: CachedNetworkImage(imageUrl: commonProvider.getUserModelSecondUser?.data?.user!.customStatusEmoji ?? "", height: 20, width: 20,),
//                     ),),
//                   Image.asset(AppImage.pinIcon,height: 15,width: 18,color: Colors.white,),
//                   commonText(text: "${commonProvider.getUserModelSecondUser?.data?.user!.pinnedMessageCount ?? 0}",fontSize: 16,fontWeight: FontWeight.w400),
//                   SizedBox(width: 6),
//                   Image.asset(AppImage.fileIcon,height: 15,width: 15,color: Colors.white,)
//                 ],),
//             )
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
//             onPressed: () {
//               // isMutedUser: signInModel.data?.user!.muteUsers!.contains(widget.oppositeUserId) ?? false != true,
//               showChatSettingsBottomSheet(userId: widget.oppositeUserId);
//             },
//           ),
//         ],
//       );
//   }
// }
