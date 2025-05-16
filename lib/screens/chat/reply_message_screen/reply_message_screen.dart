import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/get_reply_message_model.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../../main.dart';
import '../../../model/get_user_mention_model.dart';
import '../../../model/get_user_model.dart';
import '../../../providers/channel_list_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/common_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/file_service_provider.dart';
import '../../../providers/thread_provider.dart';
import '../../../socket_io/socket_io.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';

import '../../../widgets/audio_widget.dart';
import '../../camera_preview/camera_preview.dart';
import '../forward_message/forward_message_screen.dart';


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
  final FocusNode _focusNode = FocusNode();
  final chatProvider = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  String currentUserMessageId = "";
  final TextEditingController _messageController = TextEditingController();
  
  // Mention-related variables
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _showMentionList = false;
  final _textFieldKey = GlobalKey();
  int _mentionCursorPosition = 0;
  final Map<String, dynamic> userCache = {};
  GetUserModelSecondUser? userDetails;
  bool _isTextFieldEmpty = true;
  late AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _showAudioPreview = false;
  String? _previewAudioPath;
  final Map<String, Duration> _audioDurations = {};
  final _audioPlayer = AudioPlayer();

  // Replace voice_message_player related variables with:
  final Map<String, AudioPlayer> _audioPlayers = {};
  AudioPlayer? _currentlyPlayingPlayer;

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

  void _sendAudioMessage() async {
    if (_audioPath != null) {
      try {
        final uploadedFiles = await chatProvider.uploadFilesForAudio([_audioPath!]);
        // print("uploadFiles>>>> $uploadedFiles");
        // Send the message with the uploaded files

        await chatProvider.sendMessage(
          content: "",
          receiverId: widget.receiverId,
          files: uploadedFiles,
          replyId: widget.messageId,
          editMsgID: currentUserMessageId,
          isEditFromReply: true,
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

  @override
  void initState() {
    // print("msgIDD>>>> ${widget.messageId}");
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndCacheUserDetails();
      socketProvider.userTypingEvent(
        oppositeUserId: widget.receiverId,
        isReplyMsg: true,
        isTyping: 0,
        msgId: widget.messageId,
      );
      chatProvider.getReplyListUpdateSC(widget.messageId);
      chatProvider.getTypingUpdate();
      socketProvider.listenDeleteMessageSocketForReply(msgId: widget.messageId);
      socketProvider.socketListenPinMessageInReplyScreen(msgId: widget.messageId);
      socketProvider.socketListenReactMessageInReplyScreen(msgId: widget.messageId);
      // print("I'm In initState");
      Provider.of<ChatProvider>(context, listen: false).getReplyMessageList(msgId: widget.messageId,fromWhere: "SCREEN INIT");
      Provider.of<ChatProvider>(context, listen: false).seenReplayMessage(msgId: widget.messageId);
      Provider.of<CommonProvider>(context, listen: false).getUserApi(id :widget.receiverId);
      final threadProvider = Provider.of<ThreadProvider>(context, listen: false);
      threadProvider.fetchUnreadThreads();
      threadProvider.fetchUnreadThreadCount();
      _initializeRecorder();
    });
  }

  void _fetchAndCacheUserDetails() async {
    userDetails = await commonProvider.getUserByIDCallForSecondUser(userId: widget.receiverId);
    // await commonProvider.getUserByIDCallForSecondUser(userId: signInModel!.data!.user!.id);
    setState(()  {
      userCache["${commonProvider.getUserModelSecondUser?.data!.user!.sId}"] = commonProvider.getUserModelSecondUser!;
      userCache["${commonProvider.getUserModel?.data!.user!.sId}"] = commonProvider.getUserModel!;
    });
    // print("user>>>>>> ${userCache}");
    // print("user>>>>>> ${userDetails?.data!.user!.username}");
    // print("user>>>>>> ${commonProvider.getUserModelSecondUser?.data!.user!.username}");
    // print("user>>>>>> ${commonProvider.getUserModelSecondUser?.data!.user!.sId}");
  }
  late FileServiceProvider _fileServiceProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeMentionOverlay();
    _fileServiceProvider = Provider.of<FileServiceProvider>(context, listen: false);
  }
  @override
  void dispose() {
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _audioDurations.clear();
    _recordingTimer?.cancel();
    _record.dispose();
    socketProvider.userTypingEvent(
      oppositeUserId: widget.receiverId,
      isReplyMsg: true,
      isTyping:  0,
      msgId: widget.messageId,
    );
    scrollController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _fileServiceProvider.clearFilesForScreen(AppString.singleChatReply);
    super.dispose();
  }
  List<dynamic> _getFilteredUsers(String? searchQuery, CommonProvider provider) {
    final List<dynamic> initialUsers = [];
    final allUsers = provider.getUserMentionModel?.data?.users ?? [];
    final bool isSelfChat = widget.receiverId == signInModel!.data?.user?.id;

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
                (user) => user.sId == signInModel!.data?.user?.id,
          );
          final oppositeUser = allUsers.firstWhere(
                (user) => user.sId == widget.receiverId,
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
                (user) => user.sId == signInModel!.data?.user?.id &&
                ((user.username?.toLowerCase().contains(query) ?? false) ||
                    (user.fullName?.toLowerCase().contains(query) ?? false))
        );
        initialUsers.add(currentUser);
      } catch (_) {}

      try {
        final oppositeUser = allUsers.firstWhere(
                (user) => user.sId == widget.receiverId &&
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

  @override
  Widget build(BuildContext context) {
    // setTransparentStatusBar();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // pop(popValue: true);
        chatProvider.getMessagesList(oppositeUserId: widget.receiverId,currentPage: chatProvider.currentPagea,isFromMsgListen: false,onlyReadInChat: false);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              inputTextFieldWithEditor()
            ],),
          ),
          appBar: AppBar(
            leading: IconButton(onPressed: (){
              Cf.instance.pop(popValue: true);
              chatProvider.getMessagesList(oppositeUserId: widget.receiverId,currentPage: chatProvider.currentPagea,isFromMsgListen: false,onlyReadInChat: false);
            },
            icon: Icon(CupertinoIcons.back,color: Colors.white,)),
            bottom: PreferredSize(preferredSize: Size.zero , child: Divider(color: Colors.grey.shade800, height: 1,),),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Cw.instance.commonText(text: "Thread", fontSize: 16,),
              Consumer<ChatProvider>(builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Cw.instance.commonText(text:
                  (widget.receiverId == value.oppUserIdForTyping && value.msgLength == 1 && value.isTypingFor == true && value.parentId == widget.messageId)
                      ? "Typing..." : widget.userName,
                      fontSize: 12,fontWeight: FontWeight.w400),

                );
              },),
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
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  Widget dateHeaders() {
    return Consumer<ChatProvider>(builder: (context, value, child) {
      return value.getReplyMessageModel?.data?.messages?.length == 0 ? SizedBox.shrink() : ListView.builder(
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
                      child: Cw.instance.commonText(
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
      bool isEdited = messageList.isEdited ?? false;
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
                      Cw.instance.commonText(text: "Pinned",color: AppColor.blueColor)
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
                    child: Cw.instance.profileIconWithStatus(userID: "${messageList.senderId!.sId}", status: "${messageList.senderId!.status}",otherUserProfile: messageList.senderId?.thumbnailAvatarUrl ?? "",radius: 17,userName: messageList.senderId?.userName ?? ""),
                  ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Cw.instance.commonText(
                                height: 1.2,
                                text:
                                messageList.senderId?.userName ?? messageList.senderId!.fullName ?? 'Unknown', fontWeight: FontWeight.bold),
                            SizedBox(width: 5),
                            Cw.instance.commonText(
                                height: 1.2,
                                text: Cf.instance.formatTime(time), color: Colors.grey, fontSize: 12
                            ),
                          ],
                        ),
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
                                    Cw.instance.profileIconWithStatus(userID: messageList.forwardFrom?.sId ?? "", status: messageList.forwardFrom?.senderId?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.forwardFrom?.senderId?.avatarUrl, userName: messageList.forwardFrom?.senderId?.userName ?? ''),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Cw.instance.commonText(text: messageList.forwardFrom?.senderId?.userName ?? messageList.forwardFrom?.senderId?.fullName ?? ""),
                                          SizedBox(height: 3),
                                          Cw.instance.commonText(text: Cf.instance.formatDateString("${messageList.forwardFrom?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                Cw.instance.commonHTMLText(message: "${messageList.forwardFrom?.content}"),
                                Visibility(
                                  visible: messageList.forwardFrom?.files?.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwardFrom?.files?.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwardFrom?.files?[index];
                                      String originalFileName = Cf.instance.getFileName(messageList.forwardFrom?.files?[index]);
                                      String formattedFileName = Cf.instance.formatFileName(originalFileName);
                                      String fileType = Cf.instance.getFileExtension(originalFileName);
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
                                          isForwarded: true,
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
                        visible: messageList.isMedia == true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files?.length ?? 0,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files![index];
                            String originalFileName = Cf.instance.getFileName(messageList.files![index]);
                            String formattedFileName = Cf.instance.formatFileName(originalFileName);
                            String fileType = Cf.instance.getFileExtension(originalFileName);
                            // IconData fileIcon = getFileIcon(fileType);
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
                                    .map((r) => r.userId!.sId)
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
                                                onTap: () => _showReactionsList(context, messageList.reactions!),
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
                                    reaction.userId!.sId == signInModel!.data?.user?.id &&
                                        reaction.emoji == entry.key);

                                    return GestureDetector(
                                      onTap: () {
                                        if (hasUserReacted) {
                                          context.read<ChatProvider>().reactionRemove(
                                              messageId: messageList.sId!,
                                              reactUrl: entry.key,
                                              receiverId: widget.receiverId,
                                              isFrom: "Reply"
                                          );
                                        } else {
                                          context.read<ChatProvider>().reactMessage(
                                              messageId: messageList.sId!,
                                              reactUrl: entry.key,
                                              receiverId: widget.receiverId,
                                              isFrom: "Reply"
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
                                                color: hasUserReacted ? Colors.blue :
                                                AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
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
                Cw.instance.popMenuForReply2(context,
                  isPinned: pinnedMsg,
                  hasAudioFile: (messageList.files?.any((file) {
                    String fileType = Cf.instance.getFileExtension(Cf.instance.getFileName(file));
                    return fileType.toLowerCase() == 'm4a' ||
                        fileType.toLowerCase() == 'mp3' ||
                        fileType.toLowerCase() == 'wav';
                  }) ?? false) ||
                      (messageList.forwardFrom?.files?.any((file) {
                        String fileType = Cf.instance.getFileExtension(Cf.instance.getFileName(file));
                        return fileType.toLowerCase() == 'm4a' ||
                            fileType.toLowerCase() == 'mp3' ||
                            fileType.toLowerCase() == 'wav';
                      }) ?? false),
                  onOpened: () {}  ,
                  onClosed: () {} ,
                  onReact: () {
                    Cw.instance.showReactionBar(context, messageId.toString(), userId, "Reply");
                  },
                  opened:  false,
                  currentUserId: messageList.senderId?.sId ?? "",
                  onForward: () => Cf.instance.pushScreen(screen: ForwardMessageScreen(userName: messageList.senderId?.userName ?? messageList.senderId!.fullName ?? 'Unknown',time: Cf.instance.formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: "${messageList.senderId!.avatarUrl}",forwardMsgId: messageId,)),
                  onPin: () => chatProvider.pinUnPinMessageForReply(receiverId: widget.receiverId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg ),
                  onCopy: () => Cf.instance.copyToClipboard(context, parse(message).body?.text ?? ""),
                  onEdit: () => setState(() {
                    _messageController.clear();
                    FocusScope.of(context).requestFocus(_focusNode);
                    int position = _messageController.text.length;
                    currentUserMessageId = messageId;
                    // print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                    _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                  }),
                  onDelete: () => Cw.instance.deleteMessageDialog(context, ()=> chatProvider.deleteMessageForReply(messageId: messageId.toString(),firsMessageId: widget.messageId)),
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
                    /// SEND MESSAGE & CAMERA,MIC ///
                    if (!_isRecording && !_showAudioPreview) ...[
                      if(fileServiceProvider.getFilesForScreen(AppString.singleChatReply).isNotEmpty || _messageController.text.isNotEmpty)...{
                        GestureDetector(
                          onTap: () async {
                            // final plainText = _messageController.text.trim();
                            final plainText = Cf.instance.processContent(_messageController.text.trim());
                            if (fileServiceProvider.getFilesForScreen(AppString.singleChatReply).isNotEmpty || plainText.isNotEmpty) {
                              if (fileServiceProvider.getFilesForScreen(AppString.singleChatReply).isNotEmpty) {
                                final filesOfList = await chatProvider.uploadFiles(AppString.singleChatReply);
                                chatProvider.sendMessage(
                                  content: plainText,
                                  receiverId: widget.receiverId,
                                  files: filesOfList,
                                  replyId: widget.messageId,
                                  editMsgID: currentUserMessageId,
                                  isEditFromReply: true,
                                );
                              } else {
                                chatProvider.sendMessage(
                                  content: plainText,
                                  receiverId: widget.receiverId,
                                  replyId: widget.messageId,
                                  editMsgID: currentUserMessageId.isEmpty ? "" : currentUserMessageId,
                                  isEditFromReply: true,
                                ).then((value) {
                                  setState(() {
                                    currentUserMessageId = "";
                                    socketProvider.userTypingEvent(
                                      oppositeUserId: widget.receiverId,
                                      isReplyMsg: true,
                                      isTyping: 0,
                                      msgId: widget.messageId,
                                    );
                                  });
                                });
                              }
                              _clearInputAndDismissKeyboard();
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
                              // showCameraOptionsBottomSheet(context,AppString.singleChatReply);
                              Cf.instance.pushScreen(screen: CameraScreen(screenName: AppString.singleChatReply,));
                            },
                            child : Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(Icons.camera_alt_outlined, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black , size: 30),
                            )),
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
              Cw.instance.selectedFilesWidget(screenName: AppString.singleChatReply),
            ],
          ),
        ),
      );
    },);
  }

  Future<void> mediaSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : Colors.white,
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
                FileServiceProvider.instance.pickImagesAndVideo(AppString.singleChatReply);
              }),
              _optionItem(context, Icons.attach_file, "Files", "Access all Files",(){
                FileServiceProvider.instance.pickFiles(AppString.singleChatReply);
              }),
              _optionItem(context, Icons.camera_alt_outlined, "Camera", "Capture image and video",(){
                // FileServiceProvider.instance.captureImageAndVideo(AppString.singleChatReply);
                Cf.instance.pushScreen(screen: CameraScreen(screenName: AppString.singleChatReply,));
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

  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _messageController.clear();
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
        oppositeUserId: widget.receiverId,
        isReplyMsg: true,
        isTyping: text.trim().length > 1 ? 1 : 0,
        msgId: widget.messageId,
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
                                            ApiString.profileBaseUrl + (user?.avatarUrl ?? ''),
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

  void _removeMentionOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _showMentionList = false);
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

  void _showReactionsList(BuildContext context, List<Reactions> reactions) {
    // Group reactions by user
    final Map<String, List<String>> userReactions = {};
    for (var reaction in reactions) {
      if (reaction.userId != null && reaction.userId!.sId != null) {
        if (!userReactions.containsKey(reaction.userId!.sId)) {
          userReactions[reaction.userId!.sId!] = [];
        }
        if (reaction.emoji != null) {
          userReactions[reaction.userId!.sId!]!.add(reaction.emoji!);
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
