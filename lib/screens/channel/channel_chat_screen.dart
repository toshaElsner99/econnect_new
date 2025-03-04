import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/channel_chat_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/screens/channel/channel_member_info_screen/channel_members_info.dart';
import 'package:e_connect/screens/channel/channel_pinned_messages/channel_pinned_messages_screen.dart';
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
import '../../providers/file_service_provider.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/app_color_constants.dart';
import '../../utils/app_preference_constants.dart';
import '../chat/forward_message/forward_message_screen.dart';
import 'channel_info_screen/channel_info_screen.dart';

class ChannelChatScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  const ChannelChatScreen({super.key,required this.channelId,required this.channelName});

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {

  int? _selectedIndex;
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  String currentUserMessageId = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("CHANNELID>>> ${widget.channelId}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChannelChatProvider>(context,listen: false).pagination(channelId: widget.channelId);
      Provider.of<ChannelChatProvider>(context, listen: false).getChannelInfoApiCall(channelId: widget.channelId);
      Provider.of<ChannelListProvider>(context, listen: false).readUnReadChannelMessage(oppositeUserId: widget.channelId,isCallForReadMessage: true);
      Provider.of<ChannelChatProvider>(context, listen: false).getChannelChatApiCall(channelId: widget.channelId,pageNo: 1);
      Provider.of<ChannelChatProvider>(context, listen: false).getChannelMembersList(widget.channelId);
    },);
   }

  void _showRenameChannelDialog() {
    final TextEditingController _nameController = TextEditingController(text: widget.channelName);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonText(
                    text: "Rename Channel",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.whiteColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColor.whiteColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              commonText(
                text: "Display Name",
                fontSize: 14,
                color: AppColor.borderColor,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: AppColor.whiteColor),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    hintText: "Enter channel name",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: commonText(
                      text: "Cancel",
                      color: AppColor.whiteColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      final newName = _nameController.text.trim();
                      if (newName.isNotEmpty) {
                        Provider.of<ChannelListProvider>(context, listen: false)
                          .renameChannel(
                            channelId: widget.channelId,
                            name: newName,
                            isPrivate: false
                          )
                          .then((_) => Navigator.pop(context));
                      }
                    },
                    child: commonText(
                      text: "Save",
                      color: AppColor.whiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputTextFieldWithEditor(ChannelChatProvider channelChatProvider) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              style: TextStyle(color: AppColor.whiteColor),
                              decoration: InputDecoration(
                                hintText: 'Write to ${widget.channelName}',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColor.blueColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: AppColor.whiteColor, size: 20),
                    onPressed: () async {
                      final plainText = _messageController.text.trim();
                      if(plainText.isNotEmpty || fileServiceProvider.selectedFiles.isNotEmpty) {
                        if(fileServiceProvider.selectedFiles.isNotEmpty){
                          final filesOfList = await channelChatProvider.uploadFiles();
                          channelChatProvider.sendMessage(content: plainText, channelId: widget.channelId, files: filesOfList);
                        } else {
                          channelChatProvider.sendMessage(content: plainText, channelId: widget.channelId,editMsgID: currentUserMessageId).then((value) => setState(() {
                            currentUserMessageId = "";
                          }),);
                        }
                        _clearInputAndDismissKeyboard();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          selectedFilesWidget(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColor.whiteColor, size: 22),
                  onPressed: () {
                    FileServiceProvider.instance.pickFiles();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: AppColor.whiteColor, size: 22),
                  onPressed: () {
                    FileServiceProvider.instance.pickImages();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: AppColor.whiteColor, size: 22),
                  onPressed: () {
                    showCameraOptionsBottomSheet(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _messageController.clear();
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
              Row(
                children: [
                  commonText(text: widget.channelName, maxLines: 1, fontSize: 14),
                  SizedBox(width: 10),
                  GestureDetector(
                      onTap: (){
                        _showRenameChannelDialog();
                      },
                      child: Image.asset(AppImage.editIcon, height: 15, width: 15, color: AppColor.borderColor)),
                ],
              ),
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
                    onTap: () => pushScreen(screen: ChannelPinnedPostsScreen(channelName: widget.channelName, channelId: widget.channelId)),
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
            if(channelChatProvider.isChannelChatLoading )...{
              Flexible(child: customLoading())
            }else...{
              Expanded(
                child: ListView(
                  controller: channelChatProvider.scrollController,
                  reverse: true,
                  children: [
                    dateHeaders(),
                  ],
                ),
              ),
            },
            inputTextFieldWithEditor(channelChatProvider),
          ],
        ),
      );
    },);
  }
  Widget dateHeaders() {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      List<MessageGroup>? sortedGroups = channelChatProvider.messageGroups..sort((a, b) => b.id!.compareTo(a.id!));
      // List<MessageGroup>? sortedGroups = channelChatProvider.channelChatModel?.data?.messages?..sort((a, b) => b.id!.compareTo(a.id!));
      return channelChatProvider.messageGroups.isEmpty? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedGroups.length + 1,
        itemBuilder: (itemContext, index) {
          if(index == sortedGroups.length){
            if(channelChatProvider.totalPages > channelChatProvider.currentPage) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: customLoading(),
              );
            }else if(channelChatProvider.totalPages == channelChatProvider.currentPage){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    commonText(text: widget.channelName,fontSize: 18),
                    SizedBox(height: 10),
                    commonText(text: "This is the start of the ${widget.channelName} channel by ${channelChatProvider.getChannelInfo?.data?.ownerId?.username ?? ""} on ${formatDateWithYear(channelChatProvider.getChannelInfo?.data?.createdAt ?? "")}. Any member can join and read this channel.",textAlign: TextAlign.center,
                    height: 1.35),
                  ],
                ),
              );
            }else {
              return SizedBox.shrink();
            }
          }

          final group = sortedGroups[index];
          List<Message> sortedMessages = (group.messages ?? [])..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
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
                        text: formatDateTime(DateTime.parse(group.id!)),
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
                    userId: message.senderId ?? "",
                    messageId: sortedMessages[index].id.toString(),
                    message: message.content ?? "",
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
      bool pinnedMsg = messageList.isPinned ?? false;
      bool isEdited = messageList.isEdited ?? false;
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
                    child: profileIconWithStatus(userID: messageList.senderInfo?.id ?? "", status: messageList.senderInfo?.status ?? "offline",otherUserProfile: messageList.senderInfo?.avatarUrl ?? "",radius: 17),
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
                            commonText(height: 1.2, text: messageList.senderInfo?.username ?? "", fontWeight: FontWeight.bold),
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
                                  visible: messageList.forwards?.files?.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwards?.files?.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwards?.files?[index];
                                      String originalFileName = getFileName(messageList.forwards!.files?[index]);
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
                        visible: messageList.files?.length != 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files?.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files?[index];
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
                                              userID: messageList.repliesSenderInfo?[0].id ?? "",
                                              status: "",
                                              needToShowIcon: false,
                                              radius: 12,
                                              otherUserProfile: messageList.repliesSenderInfo?[0].avatarUrl ?? "",
                                            ),
                                            if (messageList.repliesSenderInfo!.length > 1)
                                              Positioned(
                                                left: 16,
                                                child: profileIconWithStatus(
                                                  userID: messageList.repliesSenderInfo?[1].id ?? "",
                                                  status: "",
                                                  needToShowIcon: false,
                                                  radius: 12,
                                                  otherUserProfile: messageList.repliesSenderInfo?[1].avatarUrl ?? "",
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
                                  text: "${messageList.replyCount} ${messageList.replyCount! > 1 ? 'replies' : 'reply'}",
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
                // Spacer(),
                Visibility(
                  visible: !(messageList.isLog ?? false),
                  child: popMenu2(
                      context,
                      isPinned: pinnedMsg,
                      createdAt: messageList.createdAt.toString(),
                      currentUserId: userId,
                      onOpened: () =>  setState(() => _selectedIndex = index),
                      onClosed: () =>  setState(() => _selectedIndex = null),
                      isForwarded: messageList.isForwarded! ? false : true,
                      opened: index == _selectedIndex ? true : false,
                      onForward: () => pushScreen(screen: ForwardMessageScreen(userName: messageList.senderInfo?.username ?? 'Unknown',time: formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: messageList.senderInfo?.avatarUrl ?? '',forwardMsgId: messageId)),
                      onReply: () {
                        // print("onReply Passing = ${messageId.toString()}");
                        // pushScreen(screen: ReplyMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', messageId: messageId.toString(),receiverId: widget.oppositeUserId,));
                      },
                      onPin: () => (){},
                      onCopy: () => copyToClipboard(context, message),
                      onEdit: ()=> setState(() {
                        FocusScope.of(context).requestFocus(_focusNode);
                        int position = _messageController.text.length;
                        currentUserMessageId = messageId;
                        print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                        _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                      }),
                      onDelete: () => Provider.of<ChannelChatProvider>(context,listen: false).deleteMessageFromChannel(messageId: messageId)),
                )
              ],
            ),
          ],
        ),
      );
    },);
  }

}
