import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/model/message_model.dart';
import 'package:e_connect/providers/download_provider.dart';
import 'package:e_connect/screens/chat/files_listing_screen/files_listing_screen.dart';
import 'package:e_connect/screens/chat/forward_message/forward_message_screen.dart';
import 'package:e_connect/screens/chat/pinned_posts_screen/pinned_posts_screen.dart';
import 'package:e_connect/screens/chat/reply_message_screen/reply_message_screen.dart';
import 'package:e_connect/socket_io/socket_io.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:provider/provider.dart';

// import '../../model/browse_and_search_channel_model.dart';
import '../../model/get_user_mention_model.dart';
import '../../providers/channel_chat_provider.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/common_provider.dart';
import '../../screens/chat/media_preview_screen.dart';
import '../../widgets/chat_profile_header.dart';
import '../bottom_nav_tabs/home_screen.dart';
import '../channel/channel_chat_screen.dart';
import '../find_message_screen/find_message_screen.dart';




class SingleChatMessageScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  final bool? calledForFavorite;
  final bool? needToCallAddMessage;
  final bool? isFromNotification;

  const SingleChatMessageScreen({super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite, this.needToCallAddMessage, this.isFromNotification});

  @override
  State<SingleChatMessageScreen> createState() => _SingleChatMessageScreenState();
}


class _SingleChatMessageScreenState extends State<SingleChatMessageScreen> {
  final chatProvider = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  final FocusNode _focusNode = FocusNode();
  String? lastSentMessage;
  final Map<String, dynamic> userCache = {};
  GetUserModelSecondUser? userDetails;
  String currentUserMessageId = "";
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showMentionList = false;
  int _mentionCursorPosition = 0;
  final TextEditingController _messageController = TextEditingController();
  bool _isTextFieldEmpty = true;
  late FileServiceProvider _fileServiceProvider;
  final ScrollController scrollController = ScrollController();
  double? _savedScrollPosition;
  String oppositeUserId = "";
  String userName = "";


  @override
  void initState() {
    super.initState();
    oppositeUserId = widget.oppositeUserId;
    userName = widget.userName ?? "";
    initializeScreen();
  }

  initializeScreen(){
    scrollController.addListener(() {
      _saveScrollPosition();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketProvider.userTypingEvent(
        oppositeUserId: oppositeUserId,
        isReplyMsg: false,
        isTyping: 0,
      );
      _fetchAndCacheUserDetails();
      print("oppositeUserId in init==> ${oppositeUserId}");
      /// this is for pagination ///
      pagination(oppositeUserId: oppositeUserId);
      commonProvider.updateStatusCall(status: "online");
      /// opposite user typing listen ///
      chatProvider.getTypingUpdate();
      /// THis Is Socket Listening Event ///
      socketProvider.listenSingleChatScreen(oppositeUserId: oppositeUserId,getSecondUserCall: (){
        fetchOppositeUserDetails();
      });
      // socketProvider.commonListenForChats(id: oppositeUserId, isSingleChat: true,getSecondUserCall: ()=> fetchOppositeUserDetails());
      /// THis is Doing for update pin message and get Message List ///
      // socketProvider.socketListenPinMessage(oppositeUserId: oppositeUserId,callFun: (){
      //   chatProvider.getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromMsgListen: true);
      //   fetchOppositeUserDetails();
      // });
      /// this for add user to chat list on home screen 3rd Expansion tiles ///
      if(widget.needToCallAddMessage == true){
        channelListProvider.addUserToChatList(selectedUserId: oppositeUserId);
      }
      // chatProvider.getFileListingInChat(oppositeUserId: oppositeUserId);
      /// this is for read message ///
      channelListProvider.readUnreadMessages(oppositeUserId: oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
      /// this is default call with page 1 for chat listing ///
      chatProvider.getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,);
      /// this is for fetch other user details and store it to cache memory ///
      /// this is for get user mention listing api ///
      commonProvider.getUserApi(id: oppositeUserId);
      commonProvider.getUserApi(id: widget.oppositeUserId);
      chatProvider.getFileListingInChat(oppositeUserId: widget.oppositeUserId);
    },);
    _messageController.addListener(_onTextChanged);
  }

  void fetchOppositeUserDetails()async{
    userDetails = await commonProvider.getUserByIDCallForSecondUser(userId: oppositeUserId);
  }
  void _fetchAndCacheUserDetails() async {
    userDetails = await commonProvider.getUserByIDCallForSecondUser(userId: oppositeUserId);
    setState(()  {
      userCache["${commonProvider.getUserModelSecondUser?.data!.user!.sId}"] = commonProvider.getUserModelSecondUser;
      userCache["${commonProvider.getUserModel?.data!.user!.sId}"] = commonProvider.getUserModel!;
    });
    // print("userCache>>>>> ${userCache[oppositeUserId]}");
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoreScrollPosition();
    _removeMentionOverlay();
    _fileServiceProvider = Provider.of<FileServiceProvider>(context, listen: false);
  }
  @override
  void dispose() {
    socketProvider.userTypingEvent(
      oppositeUserId: oppositeUserId,
      isReplyMsg: false,
      isTyping: 0,
    );
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _fileServiceProvider.clearFilesForScreen(AppString.singleChat);
    super.dispose();
  }
  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _messageController.clear();
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }
  void _removeMentionOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _showMentionList = false);
  }
  void pagination({required String oppositeUserId}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        Provider.of<ChatProvider>(context,listen: false).paginationAPICall(oppositeUserId: oppositeUserId);
      }
    });
  }
  void _saveScrollPosition() => setState(() {
    _savedScrollPosition = scrollController.position.pixels;
  });
  void _restoreScrollPosition() {
    if (_savedScrollPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(_savedScrollPosition!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonProvider,ChatProvider>(builder: (context, commonProvider,chatProvider, child) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          channelListProvider.readUnreadMessages(oppositeUserId: oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
        },
        child: Scaffold(
          appBar: buildAppBar(commonProvider, chatProvider),
          body: Column(
            children: [
              Divider(
                color: Colors.grey.shade800,
                height: 1,
              ),
              if(chatProvider.idChatListLoading || commonProvider.isLoadingGetUser)...{
                  Flexible(child: customLoading())
              }else...{
                if(userDetails != null && chatProvider.messageGroups.isEmpty )...{
                  Expanded(
                        child: Center(
                            child: ChatProfileHeader(userName: userDetails?.data?.user?.fullName ?? userDetails?.data?.user?.username ??' Unknown',
                            userImageUrl: userDetails?.data?.user?.thumbnailAvatarUrl ?? '',
                            userId: userDetails?.data?.user?.sId ?? "",
                            userStatus: userDetails?.data?.user?.status ?? "offline",
                    ))),
                  }else...{
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      reverse: true,
                      children: [
                        dateHeaders(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                },
                if(commonProvider.getUserModelSecondUser?.data?.user?.isLeft == false)...{
                  inputTextFieldWithEditor()
                }else...{
                    Container(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColor.borderColor))
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black, // Default text color
                            fontSize: 16, // Default font size
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'You are viewing an archived channel with a '),
                            TextSpan(
                              text: 'deactivated user',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make this part bold
                              ),
                            ),
                            TextSpan(text: '. New messages cannot be posted.'),
                          ],
                        ),
                      ),
                    )
                }
              },
            ],
          ),
        ),
      );
    },);
  }
  AppBar buildAppBar(CommonProvider commonProvider, ChatProvider chatProvider) {
    return AppBar(
      toolbarHeight: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            if(widget.isFromNotification ?? false) {
              pushAndRemoveUntil(screen: HomeScreen());
            }else{
              pop();
              channelListProvider.readUnreadMessages(
                oppositeUserId: oppositeUserId,
                isCalledForFav: widget.calledForFavorite ?? false,
                isCallForReadMessage: true,
              );
            }
          },
        ),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: commonText(
                  text: userName == "" ? userCache[oppositeUserId]?.data?.user?.username ?? "Loading..." : userName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Visibility(
                visible: userDetails?.data?.user?.isFavourite ?? false,
                child: Icon(Icons.star_rate_rounded, color: Colors.yellow, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getCommonStatusIcons(
                size: 15,
                status: userDetails?.data?.user?.status ?? "offline",
                assetIcon: false,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: commonText(
                  text: (oppositeUserId == chatProvider.oppUserIdForTyping && chatProvider.msgLength == 1 && chatProvider.isTypingFor == false)
                      ? "Typing..."
                      : getLastOnlineStatus(
                    userDetails?.data?.user?.status ?? ".....",
                    userDetails?.data?.user?.lastActiveTime,
                  ),
                  height: 1,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Visibility(
                visible: userDetails?.data?.user?.customStatusEmoji != null &&
                    userDetails?.data?.user?.customStatusEmoji!.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: CachedNetworkImage(
                    imageUrl: userDetails?.data?.user?.customStatusEmoji ?? "",
                    height: 20,
                    width: 20,
                    errorWidget: (context, url, error) => Icon(Icons.error, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              /// Pinned Messages & Navigation
              GestureDetector(
                onTap: () => pushScreen(
                  screen: PinnedPostsScreen(
                    userName: userName == "" ? userCache[oppositeUserId]?.data?.user?.username ?? "Loading..." : userName,
                    oppositeUserId: oppositeUserId,
                    userCache: userCache,
                  ),
                ),
                child: Row(
                  children: [
                    commonText(
                      text: "${commonProvider.getUserModelSecondUser?.data?.user?.pinnedMessageCount ?? 0}",
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Image.asset(AppImage.pinIcon, height: 18, width: 18, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              /// File & Navigation
              GestureDetector(
                onTap: () => pushScreen(
                  screen: FilesListingScreen(
                    userName: userName == "" ? userCache[oppositeUserId]?.data?.user?.username ?? "Loading..." : userName,
                    oppositeUserId: oppositeUserId
                  ),
                ),
                child: Image.asset(AppImage.fileIcon, height: 18, width: 18, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColor.whiteColor),
          onPressed: () {
            pushScreenWithTransition(FindMessageScreen()).then((value) {
              print("value>>> $value");
              if(value != null){
                if(!value['needToOpenChannelChat']){
                  if(!(oppositeUserId == value['id'])){
                    setState(() {
                      oppositeUserId = signInModel.data!.user!.id == value['id'] ? value['oppositeUserID'] : value['id'] ;
                      userName = signInModel.data!.user!.id == value['id'] ? value['oppositeUserName'] : value['name'];
                      initializeScreen();
                      // chatProvider.messageGroups.indexWhere((test)=> test.)
                    });

                  }

                }else{
                  print("Channel Id : ${value['channelId']}");
                  pushReplacement(screen: ChannelChatScreen(channelId: value['channelId'] ?? ""));
                }
                print("Name ${value['name']} and id ${value['id']} and needToOpenchanelChatScreen ${value['needToOpenChannelChat']}");
              }
            });
            // showChatSettingsBottomSheet(userId: oppositeUserId);
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
          onPressed: () {
            showChatSettingsBottomSheet(userId: oppositeUserId);
          },
        ),
      ],
    );
  }



  Widget inputTextFieldWithEditor() {
    return Container(
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
        border: Border(
          top: BorderSide(
            color: Colors.white,
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
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      // color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CompositedTransformTarget(
                            link: _layerLink,
                            child: TextField(
                              maxLines: 5,
                              minLines: 1,
                              controller: _messageController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              style: TextStyle(color: AppColor.whiteColor),
                              decoration: InputDecoration(
                                hintText: 'Write to ${userDetails?.data?.user!.username ?? userDetails?.data?.user!.fullName ?? "...."}',
                                hintMaxLines: 1,
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // const SizedBox(width: 8),
                                    // Container(
                                    //   width: 1,
                                    //   height: 25,
                                    //   color: Colors.white
                                    // ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => FileServiceProvider.instance.pickFiles(AppString.singleChat),
                                      child: const Icon(Icons.attach_file, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>  FileServiceProvider.instance.pickImages(AppString.singleChat),
                                      child: const Icon(Icons.image, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>  showCameraOptionsBottomSheet(context,AppString.singleChat),
                                      child: const Icon(Icons.camera_alt, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ),
                      ],
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
                      if(plainText.isNotEmpty || fileServiceProvider.getFilesForScreen(AppString.singleChat).isNotEmpty) {
                        if(fileServiceProvider.getFilesForScreen(AppString.singleChat).isNotEmpty){
                          final filesOfList = await chatProvider.uploadFiles(AppString.singleChat);
                          chatProvider.sendMessage(content: plainText, receiverId: oppositeUserId, files: filesOfList);
                        } else {
                          chatProvider.sendMessage(content: plainText, receiverId: oppositeUserId, editMsgID: currentUserMessageId).then((value) => setState(() {
                            currentUserMessageId = "";
                            socketProvider.userTypingEvent(
                              oppositeUserId: oppositeUserId,
                              isReplyMsg: false,
                              isTyping: 0,
                            );
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
          if(Platform.isIOS)...{
            SizedBox(height: 20)
          },
          selectedFilesWidget(screenName: AppString.singleChat),
        ],
      ),
    );
  }


  Widget dateHeaders() {
    return Consumer<ChatProvider>(builder: (context, value, child) {
      List<MessageGroups> sortedGroups = value.messageGroups..sort((a, b) => b.sId!.compareTo(a.sId!));
      return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedGroups.length + 1,
        itemBuilder: (itemContext, index) {
          if(index == sortedGroups.length){
            if(value.totalPages > value.currentPagea) {
              return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: customLoading(),
            );
            }else if(value.totalPages == value.currentPagea){
              return ChatProfileHeader(userName: userDetails?.data?.user?.fullName ?? userDetails?.data?.user?.username ??' Unknown',
                userImageUrl: userDetails?.data?.user?.thumbnailAvatarUrl ?? '',
                userId: userDetails?.data?.user?.sId ?? "",
                userStatus: userDetails?.data?.user?.status ?? "offline",
              );
            } else {
              return SizedBox.shrink();
            }
          }
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
              ListView.builder(
                itemCount: sortedMessages.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Messages message = sortedMessages[index];
                  bool showUserDetails = previousSenderId != message.senderId;
                  previousSenderId = message.senderId;
                  return chatBubble(
                    index: index, // Pass index here
                    messageList: message,
                    messageId: sortedMessages[index].sId.toString(),
                    userId: message.senderId!,
                    message: message.content!,
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
    required Messages messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
    bool showUserDetails = true,
  })  {
    // if (!userCache.containsKey(userId))  {
    //   commonProvider.getUserByIDCall2(userId: userId);
    // }
    dynamic user = userCache[userId];
    // print("userID = $userId");
    // print("user = ${(user?.data!.user!)}");
    // print("DATa = ${jsonEncode(user?.data!.user!)}");
    // print("NAME = ${user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown'}");
    print("Sender Info => ${messageList.senderOfForward}");
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      // if (!userCache.containsKey(userId) && commonProvider.getUserModel!.data!.user!.sId! == userId) {
      //   commonProvider.getUserByIDCall2(userId: userId);
      //   userCache[userId] = commonProvider.getUserModel!;
      // }

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
                    child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "${user?.data!.user!.status}",otherUserProfile: user?.data!.user!.thumbnailAvatarUrl ?? '',radius: 17),
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
                            commonText(
                                height: 1.2,
                                text:
                                user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', fontWeight: FontWeight.bold),
                            if (signInModel.data?.user!.id == user?.data!.user!.sId && commonProvider.customStatusUrl.isNotEmpty) ...{
                              SizedBox(width: 8,),
                              CachedNetworkImage(
                                width: 20,
                                height: 20,
                                imageUrl: commonProvider.customStatusUrl,
                              ),
                            } else if (userDetails?.data!.user!.customStatusEmoji != "" && userDetails?.data!.user!.customStatusEmoji != null) ...{
                            Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: CachedNetworkImage(
                                width: 20,
                                height: 20,
                                imageUrl: userDetails?.data!.user!.customStatusEmoji,
                              ),),
                            },
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: commonText(
                                  height: 1.2,
                                  text: formatTime(time), color: Colors.grey, fontSize: 12
                              ),
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
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
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
                        // Put Reacted emojis list here
                      if (messageList.reactions?.isNotEmpty ?? false)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[900] : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Reactions',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight: MediaQuery.of(context).size.height * 0.5,
                                              ),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: messageList.reactions?.length ?? 0,
                                                itemBuilder: (context, index) {
                                                  final reaction = messageList.reactions![index];
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        profileIconWithStatus(
                                                          userID: reaction.userId ?? "",
                                                          status: "online",
                                                          radius: 16,
                                                          otherUserProfile: userCache[reaction.userId]?.data?.user?.thumbnailAvatarUrl,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            reaction.username ?? "Unknown",
                                                            style: TextStyle(
                                                              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        CachedNetworkImage(
                                                          imageUrl: reaction.emoji ?? "",
                                                          height: 24,
                                                          width: 24,
                                                          errorWidget: (context, url, error) => Icon(Icons.error, size: 24),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(Icons.info_outline, size: 20),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    alignment: WrapAlignment.start,
                                    children: groupReactions(messageList.reactions!).entries.map((entry) {
                                      bool hasUserReacted = messageList.reactions!.any((reaction) =>
                                        reaction.userId == signInModel.data?.user?.id &&
                                        reaction.emoji == entry.key);

                                      return GestureDetector(
                                        onTap: () {
                                          if (hasUserReacted) {
                                            context.read<ChatProvider>().reactionRemove(
                                              messageId: messageList.sId!,
                                              reactUrl: entry.key,
                                              receiverId: oppositeUserId,
                                              isFrom: "Chat"
                                            );
                                          } else {
                                            context.read<ChatProvider>().reactMessage(
                                              messageId: messageList.sId!,
                                              reactUrl: entry.key,
                                              receiverId: oppositeUserId,
                                              isFrom: "Chat"
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: hasUserReacted ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: entry.key,
                                                height: 20,
                                                width: 20,
                                                errorWidget: (context, url, error) => Icon(Icons.error, size: 20),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                entry.value.toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: hasUserReacted ? Colors.blue : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
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
                                  profileIconWithStatus(userID: messageList.senderOfForward?.id ?? "" , status: messageList.senderOfForward?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.senderOfForward?.thumbnailAvatarUrl),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        commonText(text: "${messageList.senderOfForward?.username}"),
                                        SizedBox(height: 3),
                                        commonText(text: formatDateString("${messageList.forwardInfo?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                      ],
                                    ),
                                  ),
                                ],),
                              ),
                                Visibility(
                                    visible: messageList.forwardInfo?.content != "",
                                    child: commonHTMLText(message: "${messageList.forwardInfo?.content}")),
                                Visibility(
                                  visible: messageList.forwardInfo?.files.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwardInfo?.files.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwardInfo?.files[index];
                                      String originalFileName = getFileName(messageList.forwardInfo!.files[index]);
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
                      Visibility(
                          visible: messageList.replies?.isNotEmpty ?? false,
                          child: GestureDetector(
                            onTap: () {
                              print("Simple Passing = ${messageId.toString()}");
                              pushScreenWithTransition(
                              ReplyMessageScreen(
                                userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',
                                messageId: messageId.toString(),
                                receiverId: oppositeUserId,
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
                                              profileIconWithStatus(
                                                userID: messageList.repliesSenderInfo![0].id,
                                                status: "",
                                                needToShowIcon: false,
                                                radius: 12,
                                                otherUserProfile: messageList.repliesSenderInfo![0].thumbnailAvatarUrl,
                                              ),
                                              if (messageList.repliesSenderInfo!.length > 1)
                                                Positioned(
                                                  left: 16,
                                                  child: profileIconWithStatus(
                                                    userID: messageList.repliesSenderInfo![1].id,
                                                    status: "",
                                                    needToShowIcon: false,
                                                    radius: 12,
                                                    otherUserProfile: messageList.repliesSenderInfo![1].thumbnailAvatarUrl,
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
                                    visible: messageList.replies != null && messageList.replies!.isNotEmpty &&
                                    messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false),
                                    child: Container(
                                      margin:EdgeInsets.only(right: 5),
                                      width: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                      height: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
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
                Visibility(
                  visible: userDetails?.data?.user?.isLeft == false,
                  child: popMenu2(context,
                    isPinned: pinnedMsg,
                    onOpened: () {},
                    onClosed: () {},
                    onReact: () {
                      showReactionBar(context, messageId.toString(), oppositeUserId, "Chat");
                    },
                    isForwarded: messageList.isForwarded! ? false : true,
                    opened: false,
                    createdAt: messageList.createdAt!,
                    currentUserId: userId,
                    onForward: ()=> pushScreen(screen: ForwardMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',time: formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: user?.data!.user!.thumbnailAvatarUrl ?? '',forwardMsgId: messageId,)),
                    onReply: () => pushScreen(screen: ReplyMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', messageId: messageId.toString(),receiverId: oppositeUserId,)).then((value) {
                      // print("value>>> $value");
                      if (messageList.replies != null && messageList.replies!.isNotEmpty) {
                        for (var reply in messageList.replies!) {
                          if (reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) {
                            setState(() =>
                            reply.isSeen = true);
                          }
                        }
                      }
                    }),
                    onPin: () => chatProvider.pinUnPinMessage(receiverId: widget.oppositeUserId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg ),
                    onCopy: () => copyToClipboard(context, message),
                    onEdit: () => setState(() {
                      _messageController.clear();
                      FocusScope.of(context).requestFocus(_focusNode);
                      int position = _messageController.text.length;
                      currentUserMessageId = messageId;
                      print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                      _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                    }),
                    onDelete: () => deleteMessageDialog(context,()=> chatProvider.deleteMessage(messageId: messageId.toString(), receiverId: oppositeUserId)))),
              ],
            ),
          ],
        ),
      );
    },
    );
  }

  void _onTextChanged() {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;

    // Update text field empty state
    setState(() {
      _isTextFieldEmpty = text.isEmpty;
    });

    if (cursorPosition > 0) {
      // Check if @ was just typed
      if (text[cursorPosition - 1] == '@') {
        _mentionCursorPosition = cursorPosition;
        _showMentionOverlay();
      }
      // Check if we should keep showing the mention list and filter based on input
      else if (_showMentionList) {
        // Find the last @ before cursor
        int lastAtIndex = text.substring(0, cursorPosition).lastIndexOf('@');
        if (lastAtIndex == -1) {
          // No @ found before cursor, remove overlay
          _removeMentionOverlay();
        } else {
          // Get the search query (text between @ and cursor)
          String searchQuery = text.substring(lastAtIndex + 1, cursorPosition).toLowerCase();
          _showMentionOverlay(searchQuery: searchQuery);
        }
      }
    } else {
      // Text is empty or cursor at start, remove overlay
      _removeMentionOverlay();
    }

    // Keep existing typing event
    socketProvider.userTypingEvent(
        oppositeUserId: oppositeUserId,
        isReplyMsg: false,
        isTyping: text.trim().length > 1 ? 1 : 0
    );
  }

  void _showMentionOverlay({String? searchQuery}) {
    _removeMentionOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final maxHeight = (screenSize.height - keyboardHeight) * 0.4; // 40% of available height

        return Positioned(
          width: screenSize.width * 0.8, // 80% of screen width
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -8),
            child: Material(
              elevation: 0, // Remove shadow
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1), // Center horizontally
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Consumer<CommonProvider>(
                  builder: (context, provider, child) {
                    final usersToShow = _getFilteredUsers(searchQuery, provider);

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Channel Members Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'CHANNEL MEMBERS',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (usersToShow.isEmpty && searchQuery?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'No matching users found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: usersToShow.length,
                              itemBuilder: (context, index) {
                                final user = usersToShow[index];
                                return InkWell(
                                  onTap: () => _onMentionSelected(user),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: CachedNetworkImageProvider(
                                            ApiString.profileBaseUrl + (user?.thumbnailAvatarUrl ?? ''),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user?.username ?? 'Unknown',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (user?.fullName != null)
                                                Text(
                                                  user.fullName!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Special Mention Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              'SPECIAL MENTION',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Special mention items
                          _buildSpecialMentionItem(
                            icon: Icons.group,
                            label: '@here',
                            onTap: () => _onMentionSelected({'username': 'here'}),
                          ),
                          _buildSpecialMentionItem(
                            icon: Icons.people,
                            label: '@channel',
                            onTap: () => _onMentionSelected({'username': 'channel'}),
                          ),
                          _buildSpecialMentionItem(
                            icon: Icons.people_outline,
                            label: '@all',
                            onTap: () => _onMentionSelected({'username': 'all'}),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showMentionList = true);
  }

  Widget _buildSpecialMentionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _onMentionSelected(dynamic user) {
    final text = _messageController.text;

    // Find the last @ before cursor
    int lastAtIndex = text.substring(0, _mentionCursorPosition).lastIndexOf('@');
    if (lastAtIndex == -1) return;

    // Extract the substring after '@' to find the partial mention
    int endIndex = _mentionCursorPosition;
    while (endIndex < text.length && text[endIndex] != ' ') {
      endIndex++; // Move until space (end of mention)
    }

    // Get the text before @mention and after the partial mention
    final beforeMention = text.substring(0, lastAtIndex); // Text before @
    final afterMention = text.substring(endIndex); // Text after the partial mention

    // Handle both Users object and special mention map
    String mentionText;
    print("User type = ${user.runtimeType}");
    if (user is Users) { // Users from user_mention_model.dart
      print("user = ${user.username}");
      mentionText = '@${user.username} ';
    }else if (user is SecondUser) {
      mentionText = '@${user.username} ';
    } else if (user is Map<String, dynamic>) {
      mentionText = '@${user['username']} ';
    } else if (user is User) {
      mentionText = '@${user.username} ';
    } else {
      print("user = ${user.username}");
      return; // Invalid user object
    }

    // Update the TextField with corrected mention text
    _messageController.value = TextEditingValue(
      text: beforeMention + mentionText + afterMention,
      selection: TextSelection.collapsed(
        offset: beforeMention.length + mentionText.length, // Move cursor after mention
      ),
    );

    _removeMentionOverlay();
  }


  List<dynamic> _getFilteredUsers(String? searchQuery, CommonProvider provider) {
    final List<dynamic> initialUsers = [];
    final allUsers = provider.getUserMentionModel?.data?.users ?? [];
    final bool isSelfChat = oppositeUserId == signInModel.data?.user?.id;

    // If no search query, show prioritized users
    if (searchQuery?.isEmpty ?? true) {
      if (isSelfChat) {
        // For self chat, show first two users from API response
        if (allUsers.isNotEmpty) {
          initialUsers.add(allUsers[0]);
          if (allUsers.length > 1) {
            initialUsers.add(allUsers[1]);
          }
        }
      } else {
        // For chat with another user, show current user and opposite user first
        try {
          final currentUser = allUsers.firstWhere(
                (user) => user.sId == signInModel.data?.user?.id,
          );
          final oppositeUser = allUsers.firstWhere(
                (user) => user.sId == oppositeUserId,
          );
          initialUsers.add(currentUser);
          initialUsers.add(oppositeUser);
        } catch (_) {
          // If users not found, fallback to first two users
          if (allUsers.isNotEmpty) {
            initialUsers.add(allUsers[0]);
            if (allUsers.length > 1) {
              initialUsers.add(allUsers[1]);
            }
          }
        }
      }
      return initialUsers;
    }

    // Filter users based on search query
    final query = searchQuery!.toLowerCase();

    if (isSelfChat) {
      // For self chat, prioritize first two matching users
      final matchingUsers = allUsers.where((user) =>
      ((user.username?.toLowerCase().contains(query) ?? false) ||
          (user.fullName?.toLowerCase().contains(query) ?? false))
      ).toList();

      if (matchingUsers.isNotEmpty) {
        initialUsers.add(matchingUsers[0]);
        if (matchingUsers.length > 1) {
          initialUsers.add(matchingUsers[1]);
        }
      }
    } else {
      // For chat with another user, prioritize current user and opposite user if they match
      try {
        final currentUser = allUsers.firstWhere(
                (user) => user.sId == signInModel.data?.user?.id &&
                ((user.username?.toLowerCase().contains(query) ?? false) ||
                    (user.fullName?.toLowerCase().contains(query) ?? false))
        );
        initialUsers.add(currentUser);
      } catch (_) {}

      try {
        final oppositeUser = allUsers.firstWhere(
                (user) => user.sId == oppositeUserId &&
                ((user.username?.toLowerCase().contains(query) ?? false) ||
                    (user.fullName?.toLowerCase().contains(query) ?? false))
        );
        initialUsers.add(oppositeUser);
      } catch (_) {}
    }

    // Add other matching users
    final otherUsers = allUsers.where((user) =>
    !initialUsers.contains(user) &&
        ((user.username?.toLowerCase().contains(query) ?? false) ||
            (user.fullName?.toLowerCase().contains(query) ?? false))
    ).toList();

    return [...initialUsers, ...otherUsers];
  }

}

