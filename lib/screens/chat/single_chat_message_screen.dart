import 'dart:async';
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
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

import '../../model/get_user_mention_model.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/common_provider.dart';
import '../../widgets/audio_widget.dart';
import '../../widgets/chat_profile_header.dart';
import '../camera_preview/camera_preview.dart';
import '../channel/channel_chat_screen.dart';
import '../find_message_screen/find_message_screen.dart';
import 'package:e_connect/utils/common/shimmer_loading.dart';

class SingleChatMessageScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  final bool? calledForFavorite;
  final bool? needToCallAddMessage;
  final bool? isFromNotification;
  final bool? isFromJump;
  final dynamic jumpData;

  const SingleChatMessageScreen({super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite, this.needToCallAddMessage, this.isFromNotification,this.isFromJump,this.jumpData});

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
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();
  double? _savedScrollPosition;
  String oppositeUserId = "";
  String userName = "";
  bool NeedTocallJumpToMessage = false;
  String messageGroupId = "";
  String messageId = "";
  late AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _showAudioPreview = false;
  String? _previewAudioPath;
  final Map<String, Duration> _audioDurations = {};
  final _audioPlayer = AudioPlayer();
  String? highlightedMessageId;
  bool _showScrollToBottomButton = false;
  bool reloading = false;
  bool isFromJump = false;

  // Replace voice_message_player related variables with:
  final Map<String, AudioPlayer> _audioPlayers = {};
  AudioPlayer? _currentlyPlayingPlayer;

  // Add this method to scroll to bottom
  void reloadPageOne() {
    setState(() {
      reloading = true;
    });
    pagination(oppositeUserId: oppositeUserId);
    downStreamPagination(oppositeUserId: oppositeUserId);
    Provider.of<ChatProvider>(context,listen: false).changeCurrentPageValue(1);
    chatProvider.getMessagesList(oppositeUserId: oppositeUserId,currentPage: 1,isFromJump: false,callForFav: widget.calledForFavorite ?? false,onlyReadInChat: false,needToReload: true);
    isFromJump = false;
    _showScrollToBottomButton = false;
    highlightedMessageId = null;
    reloading = false;
    setState(() {});
  }

  Future<void> _initializeRecorder() async {
    _record = AudioRecorder();
    bool hasPermission = await _record.hasPermission();
    if (!hasPermission) {
      // print("Recording permission denied!");
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += Duration(seconds: 1);
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _record.stop();
      _stopRecordingTimer();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _showAudioPreview = true;
        _previewAudioPath = path;
      });
      // print("Recording saved at: $_audioPath");
    } else {
      if (await _record.hasPermission()) {
        final path = await _getFilePath();
        await _record.start(RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        setState(() {
          _isRecording = true;
          _recordingDuration = Duration.zero;
          _showAudioPreview = false;
        });
        _startRecordingTimer();
      }
    }
  }

  void _cancelRecording() async {
    if (_isRecording) {
      await _record.stop();
      _stopRecordingTimer();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
        _showAudioPreview = false;
      });
    }
  }

  sendAudio() async{
    if (_audioPath != null) {
      try {
        final uploadedFiles =
            await chatProvider.uploadFilesForAudio([_audioPath!]);
        // print("uploadFiles>>>> $uploadedFiles");
        // Send the message with the uploaded files
        await chatProvider.sendMessage(
          content: "",
          receiverId: oppositeUserId,
          files: uploadedFiles,
        );

        // Clear the audio state after successful send
        setState(() {
          _audioPath = null;
          _showAudioPreview = false;
          _recordingDuration = Duration.zero;
        });
      } catch (e) {
        // print("Error sending audio message: $e");
        // You might want to show an error message to the user here
      }
    }
  }

  void _sendAudioMessage() async {
    if(_showScrollToBottomButton){
      reloadPageOne();
      Future.delayed(Duration(seconds: 3),() async{
        sendAudio();
      });
    }else {
      sendAudio();
    }
  }

  @override
  void initState() {
    super.initState();
    oppositeUserId = widget.oppositeUserId;
    userName = widget.userName ?? "";
    isFromJump = widget.isFromJump ?? false;
    if(isFromJump && widget.jumpData != null){
      highlightedMessageId = widget.jumpData['messageId'];
      setState(() {
        // Ensure the state is updated with the highlighted message ID
      });
      initializeScreen(widget.jumpData['pageNO'],true,widget.jumpData['messageGroupId'],widget.jumpData['messageId']);
    }else{
      initializeScreen(1,isFromJump,"","");
    }
    _initializeRecorder();
  }


  initializeScreen(int pageNo,bool isfromJump,String msgGroup,String msgId){
    scrollController.addListener(() {_saveScrollPosition();});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print("inside post frame $oppositeUserId");
      messageGroupId = msgGroup;
      messageId = msgId;
      
      // Clean up existing socket listeners first
      socketProvider.cleanupChatListeners();
      
      socketProvider.userTypingEvent(oppositeUserId: oppositeUserId, isReplyMsg: false, isTyping: 0,);
      _fetchAndCacheUserDetails();
      // print("oppositeUserId in init==> ${oppositeUserId}");
      if(!isfromJump) {
        /// this is for pagination ///
        pagination(oppositeUserId: oppositeUserId);
        downStreamPagination(oppositeUserId: oppositeUserId);
      }
      /// opposite user typing listen ///
      chatProvider.getTypingUpdate();
      /// THis Is Socket Listening Event ///
      socketProvider.listenForSingleChatScreen(oppositeUserId: oppositeUserId,getSecondUserCall: (){
        fetchOppositeUserDetails();
      });

      if(widget.needToCallAddMessage == true){
        channelListProvider.addUserToChatList(selectedUserId: oppositeUserId);
      }

      /// this is default call with page 1 for chat listing ///
      Provider.of<ChatProvider>(context,listen: false).changeCurrentPageValue(pageNo);
      chatProvider.getMessagesList(oppositeUserId: oppositeUserId,currentPage: pageNo,isFromJump: isfromJump,callForFav: widget.calledForFavorite ?? false,onlyReadInChat: false);
      /// this is for fetch other user details and store it to cache memory ///
      /// this is for get user mention listing api ///
      commonProvider.getUserApi(id: oppositeUserId);
      if(isFromJump){
        Future.delayed(Duration(seconds: 3),()=> jumpToMessage(sortedGroups: chatProvider.messageGroups,messageGroupId: msgGroup,messageId: msgId));
      }
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
    // Dispose all audio players
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _audioDurations.clear();
    _recordingTimer?.cancel();
    _record.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _fileServiceProvider.clearFilesForScreen(AppString.singleChat);
    socketProvider.userTypingEvent(
      oppositeUserId: oppositeUserId,
      isReplyMsg: false,
      isTyping: 0,
    );
    // Clean up all chat-related socket listeners
    socketProvider.cleanupChatListeners();
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
  void downStreamPagination({required String oppositeUserId}) {
    scrollController.addListener(() {

      if (scrollController.position.pixels == 0) {
        Provider.of<ChatProvider>(context,listen: false).downStreamPaginationAPICall(oppositeUserId: oppositeUserId);
      }
    });
  }
  void jumpToMessage({required List<MessageGroups> sortedGroups,required String messageGroupId,required String messageId}){
    if(Provider.of<ChatProvider>(context,listen: false).idChatListLoading == false){
      // print("messageGroupId $messageGroupId");
      // log("messageGroupId $sortedGroups");
      final  index = sortedGroups.indexWhere((test)=> test.sId == messageGroupId.split(" ")[0]);
      final msgIndex = sortedGroups[index].messages!.indexWhere((element) => element.sId == messageId);

      // Set the highlighted message ID
      setState(() {
        highlightedMessageId = messageId;
      });

      Map<String, String> messages = {};
      for(var group in sortedGroups.reversed) {
        // print("Date = ${group.sId}");
        List<Messages> perGroupMessages = (group.messages ?? [])
          ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        for (var msg in perGroupMessages){
          // print("msg = ${msg.content}");
          // messages.addAll({msg.id! : msg.content!});
          messages[msg.sId!] = msg.content!;
          // print("INdex in loop =${messages.keys.toList().indexOf(msg.sId!)}");
        }
      }
      // print("messages = ${messages.length}");
      int newIndex = messages.keys.toList().indexOf(messageId);
      // print("Single Chat New Index $newIndex");
      if (newIndex != -1) {
        double itemHeight; // Approximate height of each message
        if(newIndex >= (messages.length-5)  && newIndex <= (messages.length-1)){
          itemHeight = 0;
          // print("itemHeight1 = $itemHeight");
        }else if(newIndex >= (messages.length-10)  && newIndex <= (messages.length-4)){
          itemHeight = 5;
          // print("itemHeight2 = $itemHeight");
        }else if(newIndex >= (messages.length-15)  && newIndex <= (messages.length-9)){
          itemHeight = 40;
          // print("itemHeight3 = $itemHeight");
        }else if(newIndex >= (messages.length-20)  && newIndex <= (messages.length-16)){
          itemHeight = 60;
          // print("itemHeight4 = $itemHeight");
        }else{
          itemHeight = 120;
          // print("itemHeight5 = $itemHeight");
        }
        final messagesInPage = (messages.length) - (newIndex % (messages.length));
        final targetPosition = messagesInPage * itemHeight;
        // print("targetPosition = $targetPosition");
        // Scroll to the message with animation
        scrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _showScrollToBottomButton = true;
        setState(() {

        });
      }
    }else{
      Future.delayed(Duration(seconds: 3),()=> jumpToMessage(sortedGroups: sortedGroups,messageGroupId: messageGroupId,messageId: messageId));
    }
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
        onPopInvokedWithResult: (x, y) {
          channelListProvider.readUnreadMessages(
            oppositeUserId: oppositeUserId,
            isCalledForFav: widget.calledForFavorite ?? false,
            isCallForReadMessage: true,
          );
          // if (widget.isFromNotification ?? false) {
          //   pushAndRemoveUntil(screen: HomeScreen());
          // }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child:  Scaffold(
            appBar: buildAppBar(commonProvider, chatProvider),
            resizeToAvoidBottomInset: true,
            bottomNavigationBar: Padding(
              padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(commonProvider.getUserModelSecondUser?.data?.user?.isLeft == true)...{
                    if(commonProvider.getUserModelSecondUser?.data?.user?.sId == "681d8ff1deb78a151b87a770")...{
                      userNotPutAnyMessageText(commonProvider.getUserModelSecondUser!.data!.user!.fullName!)
                    }else...{
                      userLeftedText()
                    }

                  }else...{
                    inputTextFieldWithEditor()
                  }
                ],),
            ),
            floatingActionButton: _showScrollToBottomButton
                ? FloatingActionButton(
              backgroundColor: AppColor.blueColor,
              onPressed: reloadPageOne,
              child: Icon(Icons.arrow_downward, color: Colors.white),
            )
                : null,
            body: Column(
              children: [
                Divider(
                  color: Colors.grey.shade800,
                  height: 1,
                ),
                if(chatProvider.idChatListLoading || commonProvider.isLoadingGetUser || reloading)...{
                  Flexible(child: ShimmerLoading.instance.chatShimmer(context))
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
                    // Expanded(
                    //   child: ListView(
                    //     controller: scrollController,
                    //     reverse: true,
                    //     children: [
                    //       dateHeaders(),
                    //     ],
                    //   ),
                    // ),
                    Expanded(
                        child: dateHeaders()
                    ),
                    SizedBox(height: 20,),
                  },
                },
              ],
            ),
          ),
        ),
      );
    },);
  }

  Container userLeftedText() {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColor.borderColor))
      ),
      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black, // Default text color
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
    );
  }
  Container userNotPutAnyMessageText(String userName) {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColor.borderColor))
      ),
      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black, // Default text color
            fontSize: 16, // Default font size
          ),
          children: <TextSpan>[

            TextSpan(text: '$userName',  style: TextStyle(
          fontWeight:
          FontWeight.bold, // Make this part bold
        ),),
            TextSpan(text: ' cannot receive messages. Check your user list for others to chat with.'),
          ],
        ),
      ),
    );
  }
  AppBar buildAppBar(CommonProvider commonProvider, ChatProvider chatProvider) {
    return AppBar(
      toolbarHeight: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            Cf.instance.pop();
            // if(widget.isFromNotification ?? false) {
            //   pushAndRemoveUntil(screen: HomeScreen());
            // }else{
            //   pop();
            // }
            channelListProvider.readUnreadMessages(
              oppositeUserId: oppositeUserId,
              isCalledForFav: widget.calledForFavorite ?? false,
              isCallForReadMessage: true,
            );
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
                child: Cw.instance.commonText(
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
              Cw.instance.getCommonStatusIcons(
                size: 15,
                status: userDetails?.data?.user?.status ?? "offline",
                assetIcon: false,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Cw.instance.commonText(
                  text: (oppositeUserId == chatProvider.oppUserIdForTyping && chatProvider.msgLength == 1 && chatProvider.isTypingFor == false)
                      ? "Typing..."
                      : Cf.instance.getLastOnlineStatus(
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
                    userDetails?.data?.user?.customStatusEmoji! != "",
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
                onTap: () => Cf.instance.pushScreen(
                  screen: PinnedPostsScreen(
                    userName: userName == "" ? userCache[oppositeUserId]?.data?.user?.username ?? "Loading..." : userName,
                    oppositeUserId: oppositeUserId,
                    userCache: userCache,
                  ),
                ),
                child: Row(
                  children: [
                    Cw.instance.commonText(
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
                onTap: () => Cf.instance.pushScreen(
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
            Cf.instance.pushScreen(screen: FindMessageScreen()).then((value) {
              // print("value>>> $value");
              if(value != null){
                if(!value['needToOpenChannelChat']){
                  // if(!(oppositeUserId == value['id'])){
                  setState(() {
                    oppositeUserId = signInModel.data!.user!.id == value['id'] ? value['oppositeUserID'] : value['id'] ;
                    // print("UserId ${oppositeUserId}");
                    userName = signInModel.data!.user!.id == value['id'] ? value['oppositeUserName'] : value['name'];
                    // NeedTocallJumpToMessage = true;
                    scrollController.dispose();
                    scrollController = ScrollController();
                    // print("PageNoooo ${value['pageNO']}");
                    // print("messageGroupId ${value['messageGroupId']}");
                    // print("messageId ${value['messageId']}");
                    initializeScreen(value['pageNO'],true,value['messageGroupId'],value['messageId']);
                    NeedTocallJumpToMessage = true;
                    isFromJump = true;
                    highlightedMessageId = null;
                    messageGroupId =value['messageGroupId'];
                  });

                  // }

                }else{
                  // print("Channel Id : ${value['channelId']}");
                  Cf.instance.pushReplacement(screen: ChannelChatScreen(channelId: value['channelId'] ?? "",isFromJump: true,jumpData: value));
                }
                // print("Name ${value['name']} and id ${value['id']} and needToOpenchanelChatScreen ${value['needToOpenChannelChat']}");
              }

              // if(value != null){
              //   if(!value['needToOpenChannelChat']){
              //     if(!(oppositeUserId == value['id'])){
              //       setState(() {
              //         oppositeUserId = signInModel.data!.user!.id == value['id'] ? value['oppositeUserID'] : value['id'] ;
              //         userName = signInModel.data!.user!.id == value['id'] ? value['oppositeUserName'] : value['name'];
              //         initializeScreen();
              //         // chatProvider.messageGroups.indexWhere((test)=> test.)
              //       });
              //
              //     }
              //
              //   }else{
              //     print("Channel Id : ${value['channelId']}");
              //     pushReplacement(screen: ChannelChatScreen(channelId: value['channelId'] ?? ""));
              //   }
              //   print("Name ${value['name']} and id ${value['id']} and needToOpenchanelChatScreen ${value['needToOpenChannelChat']}");
              // }

            });
            // showChatSettingsBottomSheet(userId: oppositeUserId);
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
          onPressed: () {
            Cw.instance.showChatSettingsBottomSheet(userId: oppositeUserId);
          },
        ),
      ],
    );
  }

  sendMsg() async{
    final plainText = Cf.instance.processContent(_messageController.text.trim());
    if (fileServiceProvider.getFilesForScreen(AppString.singleChat).isNotEmpty || plainText.isNotEmpty) {
      if (fileServiceProvider.getFilesForScreen(AppString.singleChat).isNotEmpty) {
        final filesOfList = await chatProvider.uploadFiles(AppString.singleChat);
        chatProvider.sendMessage(
            content: plainText,
            receiverId: oppositeUserId,
            files: filesOfList);
      } else {
        chatProvider.sendMessage(content: plainText, receiverId: oppositeUserId, editMsgID: currentUserMessageId).then(
              (value) => setState(() {
            currentUserMessageId = "";
            socketProvider.userTypingEvent(
              oppositeUserId: oppositeUserId,
              isReplyMsg: false,
              isTyping: 0,
            );
          }),
        );
      }
      _clearInputAndDismissKeyboard();
    }
  }


  Widget inputTextFieldWithEditor() {
    return Consumer<FileServiceProvider>(builder: (context, fileServiceProvider, child) {
      return Container(
        margin: Platform.isAndroid ? null : EdgeInsets.only(bottom: _focusNode.hasFocus ? 40 : 0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColor.borderColor,
              width: 0.2,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (!_isRecording && !_showAudioPreview) ...[
                      /// ADD ICON  ////
                      GestureDetector(
                        onTap: () => mediaSheet(context),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.blueColor,
                          ),
                          child: Icon(Icons.add,color: Colors.white,size: 25,),
                        ),
                      ),
                      SizedBox(width: 6),
                      /// TEXT FIELD ///
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppPreferenceConstants.themeModeBoolValueGet ? Color(0xFf292929) : Color(0xFFf2f2f2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CompositedTransformTarget(
                                  link: _layerLink,
                                  child: KeyboardActions(
                                    disableScroll: true,
                                    config: Cw.instance.keyboardConfigIos(_focusNode),
                                    child: TextField(
                                      maxLines: 5,
                                      minLines: 1,
                                      controller: _messageController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      style: TextStyle(color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.blackColor),
                                      decoration: InputDecoration(
                                        hintText: 'Write to ${userDetails?.data?.user!.username ?? userDetails?.data?.user!.fullName ?? "...."}',
                                        hintMaxLines: 1,
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      textCapitalization: TextCapitalization.sentences,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_isRecording) ...[
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.mic, color:AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.red, size: 24),
                            SizedBox(width: 8),
                            Text(
                              _formatDuration(_recordingDuration),
                              style: TextStyle(
                                color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.red),
                        onPressed: _cancelRecording,
                      ),
                      IconButton(
                        icon: Icon(Icons.stop, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.red),
                        onPressed: _toggleRecording,
                      ),
                    ],
                    if (_showAudioPreview) ...[
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.audio_file, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.blueColor, size: 24),
                            SizedBox(width: 8),
                            Text(
                              _formatDuration(_recordingDuration),
                              style: TextStyle(
                                color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.blueColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.red),
                        onPressed: () {
                          setState(() {
                            _showAudioPreview = false;
                            _audioPath = null;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color:AppPreferenceConstants.themeModeBoolValueGet ? Colors.white :  AppColor.blueColor),
                        onPressed: _sendAudioMessage,
                      ),
                    ],
                    if (!_isRecording && !_showAudioPreview) ...[
                      if(fileServiceProvider.getFilesForScreen(AppString.singleChat).isNotEmpty || _messageController.text.isNotEmpty )...{
                        GestureDetector(
                          onTap: () async {
                            if(_showScrollToBottomButton){
                              reloadPageOne();
                              Future.delayed(Duration(seconds: 3), () async{
                                sendMsg();
                              });
                            }else{
                              sendMsg();
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColor.blueColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.send, color: AppColor.whiteColor, size: 18)),
                        ),
                      }else...{
                        GestureDetector(
                          onTap: () {
                            _focusNode.unfocus();
                            Cf.instance.pushScreen(screen: CameraScreen(screenName: AppString.singleChat,));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.camera_alt_outlined, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black , size: 30),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColor.blueColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.mic, color: Colors.white, size: 25),
                          ),
                        ),
                      }
                    ],
                  ],
                ),
              ),
              Cw.instance.selectedFilesWidget(screenName: AppString.singleChat),
            ],
          ),
        ),
      );
    },);
  }


  Future<void> mediaSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor:  AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Content and tools",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _optionItem(context, Icons.photo_library_outlined, "Media", "Photos and Video",(){
                FileServiceProvider.instance.pickImagesAndVideo(AppString.singleChat);
              }),
              _optionItem(context, Icons.attach_file, "Files", "Access all Files",(){
                FileServiceProvider.instance.pickFiles(AppString.singleChat);
              }),
              _optionItem(context, Icons.camera_alt_outlined, "Camera", "Capture image and video",(){
                // FileServiceProvider.instance.captureImageAndVideo(AppString.singleChat);
                Cf.instance.pushScreen(screen: CameraScreen(screenName: AppString.singleChat,));
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _optionItem(BuildContext context, IconData icon, String title, String subtitle,Function onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _focusNode.unfocus();
        onTap.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dateHeaders() {
    return Consumer<ChatProvider>(builder: (context, value, child) {
      // First, merge messages by date to prevent duplicates
      Map<String, List<Messages>> mergedMessagesByDate = {};
      List<MessageGroups> sortedGroups = value.messageGroups..sort((a, b) => b.sId!.compareTo(a.sId!));

      // Merge all messages with the same date
      for (var group in sortedGroups) {
        String date = group.sId!;
        if (!mergedMessagesByDate.containsKey(date)) {
          mergedMessagesByDate[date] = [];
        }
        if (group.messages != null) {
          mergedMessagesByDate[date]!.addAll(group.messages!);
        }
      }

      // Sort messages within each date group
      mergedMessagesByDate.forEach((date, messages) {
        messages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      });

      return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        controller: scrollController,
        itemCount: isFromJump ? mergedMessagesByDate.length : mergedMessagesByDate.length + 1,
        itemBuilder: (itemContext, index) {
          if(index == mergedMessagesByDate.length){
            if(!isFromJump && value.totalPages > value.currentPagea) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Cw.instance.customLoading(),
              );
            }else if(value.totalPages == value.currentPagea){
              return ChatProfileHeader(
                userName: userDetails?.data?.user?.fullName ?? userDetails?.data?.user?.username ??' Unknown',
                userImageUrl: userDetails?.data?.user?.thumbnailAvatarUrl ?? '',
                userId: userDetails?.data?.user?.sId ?? "",
                userStatus: userDetails?.data?.user?.status ?? "offline",
              );
            } else {
              return SizedBox.shrink();
            }
          }

          String date = mergedMessagesByDate.keys.elementAt(index);
          List<Messages> messagesForDate = mergedMessagesByDate[date]!;
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
                      child: Cw.instance.commonText(
                        text: Cf.instance.formatDateTime(DateTime.parse(date)),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: messagesForDate.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, messageIndex) {
                  Messages message = messagesForDate[messageIndex];
                  bool showUserDetails = previousSenderId != message.senderId;
                  previousSenderId = message.senderId;
                  bool isHighlighted = message.sId.toString() == highlightedMessageId;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    color: isHighlighted ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                    child: chatBubble(
                      index: messageIndex,
                      messageList: message,
                      messageId: message.sId.toString(),
                      userId: message.senderId!,
                      message: message.content!,
                      time: DateTime.parse(message.createdAt!).toString(),
                      showUserDetails: showUserDetails,
                    ),
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
    // print("Sender Info => ${messageList.senderOfForward}");
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
                child: Cw.instance.newMessageDivider()),
            Visibility(
                visible: pinnedMsg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(AppImage.pinMessageIcon,height: 12,width: 12,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Cw.instance.commonText(text: "Pinned",color: AppColor.blueColor),
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
                    child: Cw.instance.profileIconWithStatus(
                        userID: "${user?.data!.user!.sId}",
                        status: "${user?.data!.user!.status}",
                        otherUserProfile: user?.data!.user!.thumbnailAvatarUrl ?? '',
                        radius: 17,
                        needToShowIcon: false,
                        borderColor: AppColor.blueColor, userName: user?.data?.user?.username ?? user?.data?.user?.fullName ?? ""
                    ),
                  )
                } else ...{
                  SizedBox(width: MediaQuery.of(context).size.width * 0.135)
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
                            Cw.instance.commonText(
                                height: 1.2,
                                text:
                                user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', fontWeight: FontWeight.bold),
                            if (signInModel.data?.user!.id == user?.data!.user!.sId) ...{
                              if (commonProvider.customStatusUrl.isNotEmpty) ...{
                                SizedBox(width: 8,),
                                CachedNetworkImage(
                                  width: 20,
                                  height: 20,
                                  imageUrl: commonProvider.customStatusUrl,
                                ),
                              }
                            } else if (userDetails?.data?.user?.customStatusEmoji != "" && userDetails?.data?.user?.customStatusEmoji != null && userDetails?.data?.user?.sId == user?.data!.user!.sId) ...{
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: CachedNetworkImage(
                                  width: 20,
                                  height: 20,
                                  imageUrl: userDetails?.data?.user?.customStatusEmoji  ?? "",
                                ),),
                            },
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Cw.instance.commonText(
                                  height: 1.2,
                                  text: Cf.instance.formatTime(time), color: Colors.grey, fontSize: 12
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
                                    child: Cw.instance.commonHTMLText(message: message),
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
                                            Cw.instance.commonText(
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
                                Cw.instance.commonText(text: "Forwarded",color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor,fontWeight: FontWeight.w500),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(children: [
                                    Cw.instance.profileIconWithStatus(
                                        userID: messageList.senderOfForward?.id ?? "" ,
                                        status: messageList.senderOfForward?.status ?? "offline",
                                        needToShowIcon: false,
                                        otherUserProfile: messageList.senderOfForward?.thumbnailAvatarUrl,
                                        borderColor: AppColor.blueColor,
                                        userName: messageList.senderOfForward?.username ?? ""
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Cw.instance.commonText(text: "${messageList.senderOfForward?.username}"),
                                          SizedBox(height: 3),
                                          Cw.instance.commonText(text: Cf.instance.formatDateString("${messageList.forwardInfo?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                messageList.forwardInfo != null ?
                                Visibility(
                                    visible: messageList.forwardInfo?.content != "",
                                    child:
                                    messageList.forwardInfo!.hrms_bdy != '' ?
                                    Cw.instance.HtmlTextOnly(htmltext: "${messageList.forwardInfo?.content}") :
                                    Cw.instance.commonHTMLText(message: "${messageList.forwardInfo?.content}"))  : SizedBox(),
                                Visibility(
                                  visible: messageList.forwardInfo?.files.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwardInfo?.files.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwardInfo?.files[index];
                                      String originalFileName = Cf.instance.getFileName(messageList.forwardInfo!.files[index]);
                                      String formattedFileName = Cf.instance.formatFileName(originalFileName);
                                      String fileType = Cf.instance.getFileExtension(originalFileName);
                                      // print("FILENAME :- ${messageList.forwardInfo!.files[index]}");
                                      // print("FILENAME :- $originalFileName");
                                      // print("FILENAME :- $formattedFileName");
                                      bool isAudioFile = fileType.toLowerCase() == 'm4a' ||
                                          fileType.toLowerCase() == 'mp3' ||
                                          fileType.toLowerCase() == 'wav';
                                      if (isAudioFile) {
                                        // print("Rendering Audio Player for: ${ApiString.profileBaseUrl}$filesUrl");
                                        return AudioPlayerWidget(
                                          audioUrl: filesUrl ?? "",
                                          audioPlayers: _audioPlayers,
                                          audioDurations: _audioDurations,
                                          onPlaybackStart: _handleAudioPlayback,
                                          currentlyPlayingPlayer: _currentlyPlayingPlayer,
                                          isForwarded: true, // Set to true for forwarded messages
                                        );
                                      }

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
                                                child: Cw.instance.commonText(text: formattedFileName,maxLines: 1)),
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
                            // print("File URL: $filesUrl");
                            String originalFileName = Cf.instance.getFileName(messageList.files![index]);
                            // print("Original File Name: $originalFileName");
                            String formattedFileName = Cf.instance.formatFileName(originalFileName);
                            String fileType = Cf.instance.getFileExtension(originalFileName);
                            // print("File Type: $fileType");

                            // Check if file is audio
                            bool isAudioFile = fileType.toLowerCase() == 'm4a' ||
                                fileType.toLowerCase() == 'mp3' ||
                                fileType.toLowerCase() == 'wav';

                            // print("Is Audio File: $isAudioFile");

                            if (isAudioFile) {
                              // print("Rendering Audio Player for: ${ApiString.profileBaseUrl}$filesUrl");
                              return AudioPlayerWidget(
                                audioUrl: filesUrl,
                                audioPlayers: _audioPlayers,
                                audioDurations: _audioDurations,
                                onPlaybackStart: _handleAudioPlayback,
                                currentlyPlayingPlayer: _currentlyPlayingPlayer,
                                isForwarded: false, // Set to false for normal messages
                              );
                            }


                            return Container(
                              margin: EdgeInsets.only(top: 4, right: 10),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.lightGreyColor),
                              ),
                              child: Row(
                                children: [
                                  Cf.instance.getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                  SizedBox(width: 20),
                                  Flexible(
                                    flex: 10,
                                    fit: FlexFit.loose,
                                    child: Cw.instance.commonText(text: formattedFileName, maxLines: 1),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () => Provider.of<DownloadFileProvider>(context, listen: false)
                                        .downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
                                    child: Image.asset(
                                      AppImage.downloadIcon,
                                      fit: BoxFit.contain,
                                      height: 20,
                                      width: 20,
                                      color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Visibility(
                        visible: messageList.replies?.isNotEmpty ?? false,
                        child: GestureDetector(
                          onTap: () {
                            // print("Simple Passing = ${messageId.toString()}");
                            Cf.instance.pushScreen(screen:
                            ReplyMessageScreen(
                              userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',
                              messageId: messageId.toString(),
                              receiverId: oppositeUserId,
                            ),
                            ).then((value) {
                              // print("value>>> $value");
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
                                            Cw.instance.profileIconWithStatus(
                                              userName: messageList.repliesSenderInfo![0].username,
                                              userID: messageList.repliesSenderInfo![0].id,
                                              status: "",
                                              needToShowIcon: false,
                                              radius: 12,
                                              otherUserProfile: messageList.repliesSenderInfo![0].thumbnailAvatarUrl,
                                              borderColor: AppColor.blueColor,
                                            ),
                                            if (messageList.repliesSenderInfo!.length > 1)
                                              Positioned(
                                                left: 16,
                                                child: Cw.instance.profileIconWithStatus(
                                                  userName: messageList.repliesSenderInfo![0].username,
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

                                Cw.instance.commonText(
                                  text: "${messageList.replyCount} ${messageList.replyCount! > 1 ? 'replies' : 'reply'}",
                                  fontSize: 12,
                                  color: AppColor.borderColor,
                                ),

                                SizedBox(width: 6),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Cw.instance.commonText(
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
                      ),
                      // Put Reacted emojis list here
                      if (messageList.reactions?.isNotEmpty ?? false)
                        Container(
                          margin: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reaction avatars section
                              Builder(builder: (context) {
                                // Get unique users who reacted
                                final uniqueUsers = messageList.reactions!
                                    .map((r) => r.userId)
                                    .where((id) => id != null)
                                    .toSet()
                                    .toList();

                                // Count total unique users for the counter
                                final totalUniqueUsers = uniqueUsers.length;

                                // Get usernames for the visible avatars (show at most 2 for direct chat)
                                final visibleUsers = uniqueUsers.take(2).toList();

                                // Calculate the width needed based on number of avatars
                                final double stackWidth = visibleUsers.isEmpty ? 0 :
                                (visibleUsers.length == 1 ? 30 : 50);

                                // Create container with avatars
                                return Container(
                                  height: 32,
                                  width: stackWidth,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      for (int i = 0; i < visibleUsers.length; i++)
                                        Positioned(
                                          left: i * 20.0, // Offset each avatar by 20 pixels
                                          child: GestureDetector(
                                            onTap: () => _showReactionsList(context, messageList.reactions!),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppPreferenceConstants.themeModeBoolValueGet ?
                                                  Colors.grey.shade900 : Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Cw.instance.profileIconWithStatus(
                                                  userID: visibleUsers[i] ?? "",
                                                  status: "",
                                                  needToShowIcon: false,
                                                  radius: 14,
                                                  otherUserProfile: userCache[visibleUsers[i]]?.data?.user?.thumbnailAvatarUrl ?? '',
                                                  borderColor: AppColor.blueColor,
                                                  userName: userCache[visibleUsers[i]]?.data?.user?.username ?? userCache[visibleUsers[i]]?.data?.user?.fullName ?? 'Unknown',
                                                  onTap: () => _showReactionsList(context, messageList.reactions!)
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              SizedBox(width: 8),

                              // Reaction emojis section - keep this part to maintain functionality
                              Flexible(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.start,
                                  children: Cw.instance.groupReactions(messageList.reactions!).entries.map((entry) {
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
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Visibility(
                    visible: userDetails?.data?.user?.isLeft == false,
                    child: Cw.instance.popMenu2(context,
                        isPinned: pinnedMsg,
                        hasAudioFile: (messageList.files?.any((file) {
                          String fileType = Cf.instance.getFileExtension(Cf.instance.getFileName(file));
                          return fileType.toLowerCase() == 'm4a' || 
                                 fileType.toLowerCase() == 'mp3' || 
                                 fileType.toLowerCase() == 'wav';
                        }) ?? false) || 
                        (messageList.forwardInfo?.files.any((file) {
                          String fileType = Cf.instance.getFileExtension(Cf.instance.getFileName(file));
                          return fileType.toLowerCase() == 'm4a' || 
                                 fileType.toLowerCase() == 'mp3' || 
                                 fileType.toLowerCase() == 'wav';
                        }) ?? false),
                        onOpened: () {},
                        onClosed: () {},
                        onReact: () {
                          Cw.instance.showReactionBar(context, messageId.toString(), oppositeUserId, "Chat");
                        },
                        isForwarded: messageList.isForwarded! ? false : true,
                        opened: false,
                        createdAt: messageList.createdAt!,
                        currentUserId: userId,
                        onForward: ()=> Cf.instance.pushScreen(screen: ForwardMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',time: Cf.instance.formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: user?.data!.user!.thumbnailAvatarUrl ?? '',forwardMsgId: messageId,)),
                        onReply: () => Cf.instance.pushScreen(screen: ReplyMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', messageId: messageId.toString(),receiverId: oppositeUserId,)).then((value) {
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
                        onPin: () => chatProvider.pinUnPinMessage(receiverId: oppositeUserId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg ),
                        onCopy: () => Cf.instance.copyToClipboard(context, parse(message).body?.text ?? ""),
                        onEdit: () => setState(() {
                          _messageController.clear();
                          FocusScope.of(context).requestFocus(_focusNode);
                          int position = _messageController.text.length;
                          currentUserMessageId = messageId;
                          // print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                          _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                        }),
                        onDelete: () => Cw.instance.deleteMessageDialog(context,()=> chatProvider.deleteMessage(messageId: messageId.toString(), receiverId: oppositeUserId)))),
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
    // print("User type = ${user.runtimeType}");
    if (user is Users) { // Users from user_mention_model.dart
      // print("user = ${user.username}");
      mentionText = '@${user.username} ';
    }else if (user is SecondUser) {
      mentionText = '@${user.username} ';
    } else if (user is Map<String, dynamic>) {
      mentionText = '@${user['username']} ';
    } else if (user is User) {
      mentionText = '@${user.username} ';
    } else {
      // print("user = ${user.username}");
      return; // Invalid us er object
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

  void _showReactionsList(BuildContext context, dynamic reactions) {
    // Group reactions by user
    final Map<String, List<String>> userReactions = {};
    for (var reaction in reactions) {
      if (reaction.userId != null) {
        if (!userReactions.containsKey(reaction.userId)) {
          userReactions[reaction.userId!] = [];
        }
        if (reaction.emoji != null) {
          userReactions[reaction.userId!]!.add(reaction.emoji!);
        }
      }
    }

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
                  itemCount: userReactions.length,
                  itemBuilder: (context, index) {
                    final userId = userReactions.keys.elementAt(index);
                    final userEmojis = userReactions[userId]!;
                    final user = userCache[userId]?.data?.user;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Cw.instance.profileIconWithStatus(
                              userID: userId,
                              status: "",
                              needToShowIcon: false,
                              radius: 16,
                              otherUserProfile: user?.thumbnailAvatarUrl ?? '',
                              borderColor: AppColor.blueColor,
                              userName: user?.username ?? "Unknown"
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.username ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: userEmojis.map((emoji) => Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: CachedNetworkImage(
                                      imageUrl: emoji,
                                      height: 20,
                                      width: 20,
                                      errorWidget: (context, url, error) => Icon(Icons.error, size: 20),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
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
  }


  void _handleAudioPlayback(String audioUrl, AudioPlayer player) {
    // If there's already an audio playing and it's different from the new one
    if (_currentlyPlayingPlayer != null && _currentlyPlayingPlayer != player) {
      _currentlyPlayingPlayer!.stop();
    }
    setState(() => _currentlyPlayingPlayer = player);
  }
}


