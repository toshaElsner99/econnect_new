import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:e_connect/model/channel_chat_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/providers/common_provider.dart';
import 'package:e_connect/screens/bottom_nav_tabs/home_screen.dart';
import 'package:e_connect/screens/channel/channel_member_info_screen/channel_members_info.dart';
import 'package:e_connect/screens/channel/channel_pinned_messages/channel_pinned_messages_screen.dart';
import 'package:e_connect/screens/channel/files_listing_channel/files_listing_in_channel_screen.dart';
import 'package:e_connect/screens/channel/reply_message_screen_channel/reply_message_screen_channel.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/common/shimmer_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../main.dart';
import '../../model/channel_members_model.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/download_provider.dart';
import '../../providers/file_service_provider.dart';
import '../../socket_io/socket_io.dart';
import '../../utils/api_service/api_string_constants.dart';
import '../../utils/app_color_constants.dart';
import '../../utils/app_preference_constants.dart';
import '../../widgets/achivement_dialog.dart';
import '../../widgets/audio_widget.dart';
import '../camera_preview/camera_preview.dart';
import '../chat/forward_message/forward_message_screen.dart';
import '../chat/single_chat_message_screen.dart';
import '../find_message_screen/find_message_screen.dart';
import 'channel_info_screen/channel_info_screen.dart';
import 'package:just_audio/just_audio.dart';


class ChannelChatScreen extends StatefulWidget {
  final String channelId;
  final bool? isFromNotification;
  // final String channelName;
  final bool? isFromJump;
  final dynamic jumpData;

  const ChannelChatScreen({super.key,required this.channelId, this.isFromNotification,this.isFromJump,this.jumpData});

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  late ConfettiController _confettiController1,_confettiController2;
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  final channelChatProviderInit = Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,listen: false);
  // int? _selectedIndex;
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  String currentUserMessageId = "";
  String channelID = "";
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController1 = ScrollController();
  final _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _showMentionList = false;
  int _mentionCursorPosition = 0;
  bool _isTextFieldEmpty = true;
  bool NeedTocallJumpToMessage = false;
  String messageGroupId = "";
  final Set<String> _playedConfettiMessages = {};
  String? highlightedMessageId;
  bool _showScrollToBottomButton = false;
  bool reloading = false;
  bool _isDialogShowing = false; // Add this flag to track dialog state

  // Add this method to scroll to bottom
  void reloadPageOne() {
    setState(() {
      reloading = true;
    });
    pagination(channelId: channelID);
    downStreamPagination(channelId: channelID);
    Provider.of<ChannelChatProvider>(context,listen: false).changeCurrentPageValue(1);
    channelChatProviderInit.getChannelChatApiCall(channelId: channelID,pageNo: 1, isFromJump: false,onlyReadInChat: true,needToReload: true);
    isFromJump = false;
    _showScrollToBottomButton = false;
    highlightedMessageId = null;
    reloading = false;
    setState(() {});
    // pushReplacement(screen: ChannelChatScreen(channelId: channelID,isFromJump: false,isFromNotification: false)).then((val){
    //   setState(() {
    //     _showScrollToBottomButton = false;
    //   });
    // });
  }

  void pagination({required String channelId}) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        Provider.of<ChannelChatProvider>(context,listen: false).paginationAPICall(channelId: channelId);
      }
    });
  }

  void downStreamPagination({required String channelId}) {
    _scrollController.addListener(() {

      if (_scrollController.position.pixels == 0) {
        Provider.of<ChannelChatProvider>(context,listen: false).downStreamPaginationAPICall(channelId: channelId);
      }
    });
  }

  void jumpToMessage({required List<MessageGroup> sortedGroups, required String messageGroupId, required String messageId}) {
    if(Provider.of<ChannelChatProvider>(context,listen: false).isChannelChatLoading == false){
      print("messageGroupId $messageGroupId");
      // log("messageGroupId $sortedGroups");
      final  index = sortedGroups.indexWhere((test)=> test.id == messageGroupId.split(" ")[0]);
      final msgIndex = sortedGroups[index].messages!.indexWhere((element) => element.id == messageId);

      // Set the highlighted message ID
      setState(() {
        highlightedMessageId = messageId;
      });

      Map<String, String> messages = {};
      for(var group in sortedGroups.reversed) {
        print("Date = ${group.id}");
        List<Message> perGroupMessages = (group.messages ?? [])
          ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        for (var msg in perGroupMessages){
          print("msg = ${msg.content}");
          // messages.addAll({msg.id! : msg.content!});
          messages[msg.id!] = msg.content!;
          print("INdex in loop =${messages.keys.toList().indexOf(msg.id!)}");
        }
      }
      print("messages = ${messages.length}");
      int newIndex = messages.keys.toList().indexOf(messageId);
      print("indexindexindexindexindex $newIndex");
      if (newIndex != -1) {
        double itemHeight; // Approximate height of each message
        if(newIndex >= (messages.length-5)  && newIndex <= (messages.length-1)){
          itemHeight = 0;
          print("itemHeight1 = $itemHeight");
        }else if(newIndex >= (messages.length-10)  && newIndex <= (messages.length-4)){
          itemHeight = 5;
          print("itemHeight2 = $itemHeight");
        }else if(newIndex >= (messages.length-15)  && newIndex <= (messages.length-9)){
          itemHeight = 40;
          print("itemHeight3 = $itemHeight");
        }else if(newIndex >= (messages.length-20)  && newIndex <= (messages.length-16)){
          itemHeight = 60;
          print("itemHeight4 = $itemHeight");
        }else{
          itemHeight = 120;
          print("itemHeight5 = $itemHeight");
        }
        final messagesInPage = (messages.length) - (newIndex % (messages.length));
        final targetPosition = messagesInPage * itemHeight;
        print("targetPosition = $targetPosition");
        // Scroll to the message with animation
        _scrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _showScrollToBottomButton = true;
        setState(() {

        });
      }

      // if(_scrollController.hasClients && _scrollController1.hasClients){
      //   // _scrollController.jumpTo(index*800.0);
      //   _scrollController.animateTo(
      //     index*800.0,
      //     duration: Duration(milliseconds: 300),
      //     curve: Curves.easeInOut,
      //   );
      //   _scrollController.animateTo(
      //     msgIndex*400.0,
      //     duration: Duration(milliseconds: 300),
      //     curve: Curves.easeInOut,
      //   );
      //   // _scrollController1.jumpTo(msgIndex*800.0);
      // }
    }else{
      Future.delayed(Duration(seconds: 3),()=> jumpToMessage(sortedGroups: sortedGroups,messageGroupId: messageGroupId,messageId: messageId));
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
      _removeMentionOverlay();
    }
    socketProvider.userTypingEventChannel(
        channelId: channelID,
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
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Consumer<ChannelChatProvider>(
                  builder: (context, provider, child) {
                    final usersToShow = _getFilteredUsers(searchQuery, provider);

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                'No matching members found',
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
                                            ApiString.profileBaseUrl + (user.avatarUrl ?? ''),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.username ?? 'Unknown',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (user.fullName != null)
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

    // Handle both MemberDetails object and special mention map
    String mentionText;
    if (user is MemberDetails) {
      mentionText = '@${user.username} ';
    } else if (user is Map<String, dynamic>) {
      mentionText = '@${user['username']} ';
    } else {
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

  List<dynamic> _getFilteredUsers(String? searchQuery, ChannelChatProvider provider) {
    final List<dynamic> initialUsers = [];
    final allMembers = provider.channelMembersList;

    // If no search query, show current user and first member
    if (searchQuery?.isEmpty ?? true) {
      // Add current user first
      final currentUser = allMembers.firstWhere(
            (member) => member.sId == signInModel.data?.user?.id,
        orElse: () => allMembers.isNotEmpty ? allMembers[0] : MemberDetails(),
      );
      initialUsers.add(currentUser);

      // Add first member who is not the current user
      if (allMembers.length > 1) {
        final otherMember = allMembers.firstWhere(
              (member) => member.sId != signInModel.data?.user?.id,
          orElse: () => allMembers[0],
        );
        if (otherMember.sId != currentUser.sId) {
          initialUsers.add(otherMember);
        }
      }
      return initialUsers;
    }

    // Filter members based on search query
    final query = searchQuery!.toLowerCase();
    final matchingMembers = allMembers.where((member) =>
    ((member.username?.toLowerCase().contains(query) ?? false) ||
        (member.fullName?.toLowerCase().contains(query) ?? false))
    ).toList();

    return matchingMembers;
  }

  late AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _showAudioPreview = false;
  String? _previewAudioPath;
  bool isFromJump = false;
  final Map<String, Duration> _audioDurations = {};
  final _audioPlayer = AudioPlayer();

  // Replace voice_message_player related variables with:
  final Map<String, AudioPlayer> _audioPlayers = {};
  AudioPlayer? _currentlyPlayingPlayer;

  Future<void> _initializeRecorder() async {
    _record = AudioRecorder();
    bool hasPermission = await _record.hasPermission();
    if (!hasPermission) {
      print("Recording permission denied!");
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
      print("Recording saved at: $_audioPath");
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
    final chatProvider = Provider.of<ChatProvider>(context,listen: false);
    if (_audioPath != null) {
      try {
        final uploadedFiles = await chatProvider.uploadFilesForAudio([_audioPath!]);
        print("uploadFiles>>>> $uploadedFiles");
        // Send the message with the uploaded files

        await channelChatProviderInit.sendMessage(content: "", channelId: channelID, files: uploadedFiles);



        // Clear the audio state after successful send
        setState(() {
          _audioPath = null;
          _showAudioPreview = false;
          _recordingDuration = Duration.zero;
        });
      } catch (e) {
        print("Error sending audio message: $e");
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
    }else{
      sendAudio();
    }

  }

  @override
  void initState() {
      _confettiController1 = ConfettiController(duration: const Duration(seconds: 5));
      _confettiController2 = ConfettiController(duration: const Duration(seconds: 5));
    super.initState();
    Provider.of<CommonProvider>(context,listen: false).getUserApi(id: signInModel.data?.user?.id ?? "");
    channelID = widget.channelId;
    isFromJump = widget.isFromJump ?? false;

    if(isFromJump && widget.jumpData != null){
      highlightedMessageId = widget.jumpData['messageId'];
      setState(() {
        // Ensure the state is updated with the highlighted message ID
      });
      initializedScreen(widget.jumpData['pageNO'],true,widget.jumpData['messageGroupId'],widget.jumpData['messageId']);
    }else{
      initializedScreen(1,isFromJump,"","");
    }
      _initializeRecorder();
  }

  initializedScreen(int pageNo,bool isfromJump,String msgGroup,String msgId){
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messageGroupId = msgGroup;
      channelChatProviderInit.getChannelChatApiCall(channelId: channelID,pageNo: pageNo, isFromJump: isfromJump,onlyReadInChat: true,needLoaderFromInItState: true);
      Provider.of<ChannelChatProvider>(context,listen: false).changeCurrentPageValue(pageNo);
      channelChatProviderInit.getChannelInfoApiCall(channelId: channelID,callFroHome: true);
      channelChatProviderInit.getChannelMembersList(channelID);
      channelChatProviderInit.getFileListingInChannelChat(channelId: channelID);
      socketProvider.listenForChannelChatScreen(channelId: channelID);
      if(!isfromJump){
        pagination(channelId: channelID);
        downStreamPagination(channelId: channelID);
      }
      if(isFromJump){
        Future.delayed(Duration(seconds: 3), (){
          jumpToMessage(sortedGroups: channelChatProviderInit.messageGroups,messageGroupId: msgGroup,messageId: msgId);
        });
      }

      /// this for socket listen in channel chat for new message and delete //
      socketProvider.userTypingEventChannel(channelId: channelID, isReplyMsg: false, isTyping:  0);
      channelChatProviderInit.getTypingUpdate(true);

    },);
  }

  late FileServiceProvider _fileServiceProvider;
  @override
  void didChangeDependencies() {
    _removeMentionOverlay();
    super.didChangeDependencies();
    _fileServiceProvider = Provider.of<FileServiceProvider>(context, listen: false);
  }
  @override
  void dispose() {
    socketProvider.cleanupChatListeners();
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    _audioDurations.clear();
    _recordingTimer?.cancel();
    _record.dispose();
    _confettiController1.stop();
    _confettiController2.stop();
    _confettiController1.dispose();
    _confettiController2.dispose();
    _messageController.removeListener(_onTextChanged);
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _fileServiceProvider.clearFilesForScreen(AppString.channelChat);
    socketProvider.userTypingEventChannel(
        channelId: channelID,
        isReplyMsg: false,
        isTyping:  0
    );
    socketProvider.connectSocket();
    super.dispose();
  }

  void _showRenameChannelDialog() {
    final channelChatProv = Provider.of<ChannelChatProvider>(context,listen: false);
    final TextEditingController _nameController = TextEditingController(text: channelChatProv.getChannelInfo?.data?.name ?? "");

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : Colors.white,
        // backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.borderColor.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
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
                  Cw.instance.commonText(
                    text: "Rename Channel",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Cw.instance.commonText(
                text: "Display Name",
                fontSize: 14,
                color: AppColor.borderColor,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  // color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: 'Write to ${channelChatProv.getChannelInfo?.data?.name ?? ""}',
                    hintStyle: TextStyle(color: AppColor.lightGreyColor.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Cw.instance.commonText(
                      text: "Cancel",
                      color: AppColor.whiteColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  AppColor.blueColor ,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      final newName = _nameController.text.trim();
                      if (newName.isNotEmpty) {
                        Provider.of<ChannelListProvider>(context, listen: false)
                            .renameChannel(
                            channelId: channelID,
                            name: newName,
                            isPrivate: channelChatProv.getChannelInfo?.data?.isPrivate ?? false
                        )
                            .then((_) => Cf.instance.pop());
                      }else {
                        Cw.instance.commonShowToast("Add channel name to proceed");
                      }
                    },
                    child: Cw.instance.commonText(
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
  Path drawStar(Size size) {
    // Method to convert degrees to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  sendMsg(channelChatProvider) async{
    // var plainText = _messageController.text.trim();
    var plainText = Cf.instance.processContent(_messageController.text.trim());
    if (plainText.contains(RegExp(r':[Ww][Aa][Ff][Ff][Ll][Ee]'))) {
      plainText = plainText.replaceAll(RegExp(r':[Ww][Aa][Ff][Ff][Ll][Ee]'), ':waffle');
    }
    if(fileServiceProvider.getFilesForScreen(AppString.channelChat).isNotEmpty || plainText.isNotEmpty) {
      if(fileServiceProvider.getFilesForScreen(AppString.channelChat).isNotEmpty){
        final filesOfList = await channelChatProvider.uploadFiles(AppString.channelChat);
        channelChatProvider.sendMessage(content: plainText, channelId: channelID, files: filesOfList);
      } else {
        channelChatProvider.sendMessage(content: plainText, channelId: channelID,editMsgID: currentUserMessageId).then((value) => setState(() {
          currentUserMessageId = "";
          socketProvider.userTypingEventChannel(
              channelId: channelID,
              isReplyMsg: false,
              isTyping:  0
          );
        }),);
      }
      _clearInputAndDismissKeyboard();
    }
  }

  Widget inputTextFieldWithEditor(ChannelChatProvider channelChatProvider) {
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
                                        hintText: 'Message....',
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
                      if(fileServiceProvider.getFilesForScreen(AppString.channelChat).isNotEmpty || _messageController.text.isNotEmpty)...{
                        GestureDetector(
                          onTap: () async {
                            if(_showScrollToBottomButton){
                              reloadPageOne();
                              Future.delayed(Duration(seconds: 3), () async{
                                sendMsg(channelChatProvider);
                              });
                            }else{
                              sendMsg(channelChatProvider);
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
                              // showCameraOptionsBottomSheet(context,AppString.channelChat);
                              Cf.instance.pushScreen(screen: CameraScreen(screenName: AppString.channelChat,));
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
              Cw.instance.selectedFilesWidget(screenName: AppString.channelChat),
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
                FileServiceProvider.instance.pickImagesAndVideo(AppString.channelChat);
              }),
              _optionItem(context, Icons.attach_file, "Files", "Access all Files",(){
                FileServiceProvider.instance.pickFiles(AppString.channelChat);
              }),
              _optionItem(context, Icons.camera_alt_outlined, "Camera", "Capture image and video",(){
                // FileServiceProvider.instance.captureImageAndVideo(AppString.channelChat);
                Cf.instance.pushScreen(screen: CameraScreen(screenName: AppString.channelChat,));
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      // setTransparentStatusBar();
      return PopScope(
        onPopInvokedWithResult: (x, y) {
          Provider.of<ChannelListProvider>(context, listen: false).readUnReadChannelMessage(oppositeUserId: channelID,isCallForReadMessage: true);
          // if (widget.isFromNotification ?? false) {
          //   // pushAndRemoveUntil(screen: HomeScreen());
          // } else {
          //   // return true;
          // }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              toolbarHeight: 60,
              titleSpacing: 0,
              leading: IconButton(
                icon: Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: () {
                  Cf.instance.pop();
                  // if(widget.isFromNotification ?? false) {
                  //   // pushAndRemoveUntil(screen: HomeScreen());
                  //
                  // }else{
                  //   pop();
                  // }
                  Provider.of<ChannelListProvider>(context, listen: false).readUnReadChannelMessage(oppositeUserId: channelID,isCallForReadMessage: true);
                },
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Cw.instance.commonText(
                          text: channelChatProvider.isChannelChatLoading ? "Loading..." :  channelChatProvider.getChannelInfo?.data?.name ?? "",
                          maxLines: 1,
                          fontSize: 14,
                        ),
                      ),
                      if (channelChatProvider.getChannelInfo?.data?.members
                          ?.any((member) => member.isAdmin == true &&
                          member.id == signInModel.data?.user?.id) ?? false)...{
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _showRenameChannelDialog(),
                            child: Image.asset(
                              AppImage.editIcon,
                              height: 15,
                              width: 15,
                              color: AppColor.borderColor,
                            ),
                          ),
                        }
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // Ensures proper alignment
                    children: [
                      /// User Count & Navigation ///
                      GestureDetector(
                        onTap: () {
                          if (channelChatProvider.getChannelInfo?.data?.members?.isNotEmpty ?? false) {
                            Cf.instance.pushScreen(
                              screen: ChannelMembersInfo(
                                channelId: channelID,
                                channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              Image.asset(AppImage.person, height: 18, width: 18, color: AppColor.white),
                              SizedBox(width: 4),
                              Cw.instance.commonText(
                                text: "${channelChatProvider.getChannelInfo?.data?.members?.length ?? 0}",
                                fontSize: 15,
                                color: AppColor.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ),
                      /// Pin Messages & Navigation ///
                      GestureDetector(
                        onTap: () => Cf.instance.pushScreen(
                          screen: ChannelPinnedPostsScreen(
                            channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",
                            channelId: channelID,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              Image.asset(AppImage.pinIcon, height: 18, width: 18, color: Colors.white),
                              SizedBox(width: 4),
                              Cw.instance.commonText(
                                text: "${channelChatProvider.getChannelInfo?.data?.pinnedMessagesCount ?? 0}",
                                fontSize: 15,
                                color: AppColor.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                      ),
                      /// File & Navigation ///
                      GestureDetector(
                        onTap: () => Cf.instance.pushScreen(
                          screen: FilesListingScreen(
                            channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",
                            channelId: channelID,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Consistent padding
                          child: Image.asset(AppImage.fileIcon, height: 18, width: 18, color: AppColor.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColor.whiteColor),
                  onPressed: () {
                    Cf.instance.pushScreen(screen:FindMessageScreen()).then((value) {
                      print("value>>> $value");
                      // if(value != null){
                      //   if(value['needToOpenChannelChat']){
                      //     if(!(channelID == value['channelId'])){
                      //       setState(() {
                      //         channelID = value['channelId'];
                      //         initializedScreen();
                      //       });
                      //     }
                      //   }else{
                      //     print("userName : ${value['name']} && userId ${value['id']}");
                      //     pushReplacement(screen: SingleChatMessageScreen(userName: value['name'], oppositeUserId: value['id'],));
                      //   }
                      //   print("Name ${value['name']} and id ${value['id']} and needToOpenchanelChatScreen ${value['needToOpenChannelChat']}");
                      // }
                      if(value != null){
                        if(value['needToOpenChannelChat']){
                          // if(!(channelID == value['channelId'])){
                          setState(() {
                            channelID = value['channelId'];
                            _scrollController.dispose();
                            _scrollController = ScrollController();
                            isFromJump = true;
                            initializedScreen(value['pageNO'],true,value['messageGroupId'],value['messageId']);
                            NeedTocallJumpToMessage = true;
                            messageGroupId =value['messageGroupId'];
                            highlightedMessageId = null;
                            // Provider.of<ChannelListProvider>(context, listen: false).readUnReadChannelMessage(oppositeUserId: channelID,isCallForReadMessage: true);
                          });
                          // }
                        }else{
                          print("userName : ${value['name']} && userId ${value['id']}");
                          Cf.instance.pushReplacement(screen: SingleChatMessageScreen(userName: signInModel.data!.user!.id == value['id'] ? value['oppositeUserName'] : value['name'], oppositeUserId:signInModel.data!.user!.id == value['id'] ?value['oppositeUserID'] : value['id'],isFromJump: true,jumpData: value,));
                        }
                        print("Name ${value['name']} and id ${value['id']} and needToOpenchanelChatScreen ${value['needToOpenChannelChat']}");
                      }

                    });
                    // showChatSettingsBottomSheet(userId: oppositeUserId);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info, color: AppColor.whiteColor),
                  onPressed: () => Cf.instance.pushScreen(
                    screen: ChannelInfoScreen(
                      channelId: channelID,
                      channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",
                      isPrivate: false,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Padding(
              padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  inputTextFieldWithEditor(channelChatProvider)
                ],),
            ),
            floatingActionButton: _showScrollToBottomButton
                ? FloatingActionButton(
              backgroundColor: AppColor.blueColor,
              onPressed: reloadPageOne,
              child: Icon(Icons.arrow_downward, color: Colors.white),
            )
                : null,
            body: Stack(
              children: [
                Column(
                  children: [
                    Divider(color: Colors.grey.shade800, height: 1,),
                    if(channelChatProvider.isChannelChatLoading || reloading)...{
                      Flexible(child: ShimmerLoading.instance.chatShimmer(context))
                    }else...{
                      // Expanded(
                      //   child: ListView(
                      //     controller: _scrollController,
                      //     reverse: true,
                      //     children: [
                      //       dateHeaders(),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                          child: dateHeaders()
                      ),
                    },
                    // SizedBox(height: 20),
                    // Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
                    //   var filteredTypingUsers = channelChatProvider.typingUsers
                    //       .where((user) => user['user_id'].toString() != signInModel.data?.user?.id.toString()
                    //       && user['routeId'] == channelID).toList();
                    //   String typingMessage;
                    //
                    //   if (filteredTypingUsers.isEmpty) {
                    //     typingMessage = "";
                    //   } else if (filteredTypingUsers.length == 1) {
                    //     typingMessage = "${filteredTypingUsers[0]['username']} is Typing...";
                    //   } else {
                    //     var usernames = filteredTypingUsers.map((user) => user['username']).toList();
                    //     var lastUser  = usernames.removeLast(); // Get the last username
                    //     typingMessage = "${usernames.join(', ')}, and $lastUser  are Typing..."; // Join the rest with commas
                    //   }
                    //
                    //   return Container(
                    //     margin: EdgeInsets.only(right: 20,left : 20, top: 15,bottom: 6),
                    //     alignment: Alignment.centerLeft,
                    //     child: Column(
                    //       children: [
                    //         // Other widgets...
                    //         if (typingMessage.isNotEmpty)
                    //           commonText(text:
                    //             typingMessage,
                    //               fontSize: 14,
                    //               color: Colors.grey.shade600,
                    //               fontWeight: FontWeight.w400,
                    //           ),
                    //       ],
                    //     ),
                    //   );
                    // },),
                    Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
                      var filteredTypingUsers = channelChatProvider.typingUsers
                          .where((user) => user['user_id'].toString() != signInModel.data?.user?.id.toString()
                          && user['routeId'] == channelID
                          && user['isReply'] == false).toList();

                      String typingMessage;

                      if (filteredTypingUsers.isEmpty) {
                        typingMessage = "";
                      } else if (filteredTypingUsers.length == 1) {
                        typingMessage = "${filteredTypingUsers[0]['username']} is Typing...";
                      } else {
                        var usernames = filteredTypingUsers.map((user) => user['username']).toList();
                        var lastUser  = usernames.removeLast();
                        typingMessage = "${usernames.join(', ')}, and $lastUser are Typing...";
                      }

                      return Container(
                        margin: EdgeInsets.only(right: 20, left: 20, top: 15, bottom: 6),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            if (typingMessage.isNotEmpty)
                              Cw.instance.commonText(
                                text: typingMessage,
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                          ],
                        ),
                      );
                    },),

                  ],
                ),
                Visibility(
                // visible : channelID == "67fdfe38eb1f5907bf48e624" ? true : false,
                visible : channelID == AppPreferenceConstants.elsnerChannelGetId ? true : false,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController1,
                      blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple
                      ], // manually specify the colors to be used
                      createParticlePath: drawStar,
                    ),
                  ),
                ),
                Visibility(
                  // visible : channelID == "67fdfe38eb1f5907bf48e624" ? true : false,
                  visible : channelID == AppPreferenceConstants.elsnerChannelGetId ? true : false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController2,
                      shouldLoop: false,
                      blastDirection: -pi / 2,
                      emissionFrequency: 0.01,
                      numberOfParticles: 20,
                      maxBlastForce: 100,
                      minBlastForce: 80,
                      gravity: 0.3,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    },);
  }
  Widget dateHeaders() {
    return Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
      final adminMembers = channelChatProvider.channelMembersList
          .where((MemberDetails member) => member.isAdmin == true)
          .toList();
      final isCurrentUserAdmin = adminMembers.any((member) =>
      member.isAdmin == true &&
          member.sId == signInModel.data?.user?.id);

      // Sort and merge message groups by date
      Map<String, List<Message>> mergedMessagesByDate = {};
      List<MessageGroup> sortedGroups = channelChatProvider.messageGroups..sort((a, b) => b.id!.compareTo(a.id!));

      // Merge messages with the same date
      for (var group in sortedGroups) {
        String date = group.id!;
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

      return channelChatProvider.messageGroups.isEmpty ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Cw.instance.commonText(text: channelChatProvider.getChannelInfo?.data?.name ?? "",fontSize: 22),
            SizedBox(height: 10),
            Cw.instance.commonText(text: "This is the start of the ${channelChatProvider.getChannelInfo?.data?.name ?? ""} channel by ${channelChatProvider.getChannelInfo?.data?.ownerId?.username ?? ""} on ${Cf.instance.formatDateWithYear(channelChatProvider.getChannelInfo?.data?.createdAt ?? "")}. Any member can join and read this channel.",
                fontSize: 14,height: 1.35),
            Visibility(
              visible: isCurrentUserAdmin,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPeopleToChannel(
                          channelId: channelID,
                          channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.person_add, color: Colors.white),
                  label: Text(
                    'Add members to this private channel',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        controller: _scrollController,
        itemCount: isFromJump ? mergedMessagesByDate.length : mergedMessagesByDate.length + 1,
        itemBuilder: (itemContext, index) {
          if(index == mergedMessagesByDate.length){
            if(!isFromJump && channelChatProvider.totalPages > channelChatProvider.currentPage) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Cw.instance.customLoading(),
              );
            }else if(channelChatProvider.totalPages == channelChatProvider.currentPage){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Cw.instance.commonText(text: channelChatProvider.getChannelInfo?.data?.name ?? "",fontSize: 22),
                    SizedBox(height: 10),
                    Cw.instance.commonText(text: "This is the start of the ${channelChatProvider.getChannelInfo?.data?.name ?? ""} channel by ${channelChatProvider.getChannelInfo?.data?.ownerId?.username ?? ""} on ${Cf.instance.formatDateWithYear(channelChatProvider.getChannelInfo?.data?.createdAt ?? "")}. Any member can join and read this channel.",
                        fontSize: 14,height: 1.35),
                    Visibility(
                      visible: isCurrentUserAdmin,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPeopleToChannel(
                                  channelId: channelID,
                                  channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.person_add, color: Colors.white),
                          label: Text(
                            'Add members to this private channel',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }else {
              return SizedBox.shrink();
            }
          }

          String date = mergedMessagesByDate.keys.elementAt(index);
          List<Message> messagesForDate = mergedMessagesByDate[date]!;
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
                  Message message = messagesForDate[messageIndex];
                  bool showUserDetails = previousSenderId != message.senderId;
                  previousSenderId = message.senderId;
                  bool isHighlighted = message.id.toString() == highlightedMessageId;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    color: isHighlighted ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                    child: chatBubble(
                      index: messageIndex,
                      messageList: message,
                      showUserDetails: showUserDetails,
                      userId: message.senderId ?? "",
                      messageId: message.id.toString(),
                      message: message.content ?? "",
                      time: DateTime.parse(message.createdAt.toString()).toString(),
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

  bool isValid(username){
    print("userName >>>>>$username");
    bool isValidUser = Provider.of<CommonProvider>(context,listen: false).isUserInAllUsers(username);
    return isValidUser;
  }

  // bool shouldShowWaffle(String message,CommonProvider commonProvider) {
  //   RegExp mentionRegex = RegExp(r"@(\w+)");
  //   List<Match> mentionMatches = mentionRegex.allMatches(message).toList();
  //
  //   // Get the first mention (if any)
  //   String? mentionedUsername = mentionMatches.isNotEmpty ? mentionMatches.first.group(1) : null;
  //
  //   bool hasOneWaffle = RegExp(r":waffle").allMatches(message).length == 1;
  //   bool hasSingleMention = mentionMatches.length == 1; // Ensure only one mention
  //   bool isUserValid = hasSingleMention && mentionedUsername != null && commonProvider.isUserInAllUsers(mentionedUsername);
  //   bool hasAdditionalText = message
  //       .replaceAll(RegExp(r":waffle|@\w+"), "")
  //       .replaceAll(RegExp(r"[\s,]+"), "")
  //       .isNotEmpty;
  //
  //   return hasOneWaffle && hasSingleMention && isUserValid && hasAdditionalText;
  // }
  bool shouldShowWaffle(String message, CommonProvider commonProvider) {
    // Check for exactly one :waffle in lowercase
    // bool hasOneWaffle = RegExp(r':waffle').allMatches(message).length == 1;
    bool hasOneWaffle = RegExp(r':waffle', caseSensitive: false).allMatches(message).length == 1;

    // Check for exactly one user mention
    // RegExp mentionRegex = RegExp(r'@(\w+)');
    RegExp mentionRegex = RegExp(r'@(\w+)'); // Supports usernames like @bhavik_maru
    List<Match> mentionMatches = mentionRegex.allMatches(message).toList();
    bool hasSingleMention = mentionMatches.length == 1;

    // Check if mentioned user exists
    String? mentionedUsername = mentionMatches.isNotEmpty ? mentionMatches.first.group(1) : null;
    bool isUserValid = hasSingleMention && mentionedUsername != null && commonProvider.isUserInAllUsers(mentionedUsername);

    // Check for additional text (not just whitespace)
    // bool hasAdditionalText = message
    //     .replaceAll(RegExp(r':waffle|@\w+'), '') // Remove waffle and mention
    //     .replaceAll(RegExp(r'[\s,]+'), '') // Remove whitespace and commas
    //     .isNotEmpty;
    bool hasAdditionalText = message
        .replaceAll(RegExp(r':waffle', caseSensitive: false), '') // Remove waffle
        .replaceAll(mentionRegex, '') // Remove @username
        .trim() // Remove leading/trailing spaces
        .isNotEmpty;

    return hasOneWaffle && hasSingleMention && isUserValid && hasAdditionalText;
  }
  bool shouldShowWaffleChatGpt(String message, CommonProvider commonProvider) {
    // Check for exactly one :waffle (case-insensitive)
    bool hasOneWaffle = RegExp(r':waffle', caseSensitive: false).allMatches(message).length == 1;

    // Check for exactly one user mention
    RegExp mentionRegex = RegExp(r'@([\w.-]+)'); // Support dots and hyphens in usernames
    List<Match> mentionMatches = mentionRegex.allMatches(message).toList();
    bool hasSingleMention = mentionMatches.length == 1;

    // Extract and validate mentioned username
    String? mentionedUsername = mentionMatches.isNotEmpty ? mentionMatches.first.group(1) : null;
    bool isUserValid = hasSingleMention && mentionedUsername != null && commonProvider.isUserInAllUsers(mentionedUsername);

    // Ensure there is meaningful additional text
    bool hasAdditionalText = message
        .replaceAll(RegExp(r':waffle', caseSensitive: false), '') // Remove waffle
        .replaceAll(mentionRegex, '') // Remove @username
        .trim() // Trim extra spaces
        .isNotEmpty;

    return hasOneWaffle && hasSingleMention && isUserValid && hasAdditionalText;
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
      final user = channelChatProvider.getUserById(userId);
      bool pinnedMsg = messageList.isPinned ?? false;
      bool isEdited = messageList.isEdited ?? false;

      // if (channelID == "67fdfe38eb1f5907bf48e624" && messageList.isSeen == false) {
      if (channelID == AppPreferenceConstants.elsnerChannelGetId && messageList.isSeen == false) {
        final loggedInUserId = signInModel.data?.user?.id;

        // Ensure exactly one :waffle is present
        bool hasOneWaffle = RegExp(r':waffle', caseSensitive: false).allMatches(message).length == 1;

        // Ensure at least one user mention (@username)
        RegExp mentionRegex = RegExp(r'@[\w_]+'); // Supports usernames like @bhavik_maru
        List<Match> mentionMatches = mentionRegex.allMatches(message).toList();
        bool hasAtLeastOneMention = mentionMatches.length >= 1; // Must have at least one mention

        // Ensure additional text exists besides :waffle and mentions
        String cleanedMessage = message
            .replaceAll(RegExp(r':waffle', caseSensitive: false), '') // Remove :waffle
            .replaceAll(mentionRegex, '') // Remove mentions
            .replaceAll(RegExp(r'[\s,]+'), '') // Remove extra spaces or commas
            .trim();

        bool hasAdditionalText = cleanedMessage.isNotEmpty; // Ensure some text is left

        if (hasOneWaffle &&
            hasAtLeastOneMention &&
            hasAdditionalText &&
            !(messageList.readBy?.contains(loggedInUserId) ?? false) &&
            (messageList.taggedUsers?.length == 1 && messageList.taggedUsers?.first == loggedInUserId) && // Ensure only one tag, and it's the current user
            !_playedConfettiMessages.contains(messageList.id)) {
          
          // Play confetti immediately
          _confettiController1.play();
          _confettiController2.play();
          
          // Update message state first
          messageList.isSeen = true;
          messageList.readBy ??= [];
          if (!messageList.readBy!.contains(loggedInUserId)) {
            messageList.readBy!.add(loggedInUserId!);
          }
          _playedConfettiMessages.add(messageList.id!);

          // Show dialog after a microtask to ensure it's outside the build phase
          if (!_isDialogShowing) {
            _isDialogShowing = true;
            Future.microtask(() {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AchievementPopup(
                    title: 'Congratulations! 🎉',
                    description: 'You\'ve received a waffle!',
                    achievementType: 'milestone',
                    onClose: () {
                      Navigator.pop(context);
                      _isDialogShowing = false;
                    },
                  ),
                );
              }
            });
          }
        }
      }


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
                    // child: profileIconWithStatus(userID: messageList.senderInfo?.id ?? "", status: messageList.senderInfo?.status ?? "offline",otherUserProfile: messageList.senderInfo?.avatarUrl ?? "",radius: 17),
                    child: Cw.instance.profileIconWithStatus(userID:  messageList.senderInfo?.id ?? user?.sId ?? "", status:  messageList.senderInfo?.status ?? user?.status ?? "offline",otherUserProfile: messageList.senderInfo?.avatarUrl ?? user?.avatarUrl ?? "",radius: 17,userName: messageList.senderInfo?.username ?? ""),
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
                            Cw.instance.commonText(height: 1.2, text: messageList.senderInfo?.username ?? user?.username ?? "", fontWeight: FontWeight.bold),
                            Visibility(
                              visible: (messageList.senderInfo?.customStatusEmoji != null && messageList.senderInfo!.customStatusEmoji!.isNotEmpty) ||
                                  (user?.customStatusEmoji != null && user!.customStatusEmoji!.isNotEmpty),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: CachedNetworkImage(
                                  width: 20,
                                  height: 20,
                                  imageUrl: messageList.senderInfo?.customStatusEmoji ?? user?.customStatusEmoji ?? "",
                                ),
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(left: 5.0),
                              child: Cw.instance.commonText(height: 1.2, text: Cf.instance.formatTime(time), color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      SizedBox(height: 5),

                      /// waffle ///
                      // if (channelID == "67fdfe38eb1f5907bf48e624")...{
                      if (channelID == AppPreferenceConstants.elsnerChannelGetId)...{
                        Visibility(
                          visible: shouldShowWaffle( message, commonProvider),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Image.asset(AppImage.wafflePNG, height: 60, width: 60),
                          ),
                        ),
                      },
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
                                    child: Cw.instance.commonHTMLText(message: message.replaceAll(":waffle", ""),userId: messageList.senderInfo?.id ?? "",isLog: messageList.isLog ?? false,userName: messageList.senderInfo?.username ?? ""),
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

                      // Forwarded message section
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
                                    Cw.instance.profileIconWithStatus(userID: messageList.senderOfForward?.id ?? "", status: messageList.senderOfForward?.status ?? "offline" ,needToShowIcon: false,otherUserProfile: messageList.senderOfForward?.avatarUrl ?? "",userName: messageList.senderOfForward?.username ?? ''),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Cw.instance.commonText(text: messageList.senderOfForward?.username ?? "unknown"),
                                          SizedBox(height: 3),
                                          Cw.instance.commonText(text: Cf.instance.formatDateString("${messageList.forwards?.createdAt ?? ""}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                Visibility(
                                    visible: messageList.forwards?.content != "",
                                    child: Cw.instance.commonHTMLText(message: "${messageList.forwards?.content}")),
                                Visibility(
                                  visible: messageList.forwards?.files?.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwards?.files?.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwards?.files?[index];
                                      String originalFileName = Cf.instance.getFileName(messageList.forwards!.files?[index]);
                                      String formattedFileName = Cf.instance.formatFileName(originalFileName);
                                      String fileType = Cf.instance.getFileExtension(originalFileName);
                                      bool isAudioFile = fileType.toLowerCase() == 'm4a' ||
                                          fileType.toLowerCase() == 'mp3' ||
                                          fileType.toLowerCase() == 'wav';
                                      if (isAudioFile) {
                                        print("Rendering Audio Player for: ${ApiString.profileBaseUrl}$filesUrl");
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
                        visible: messageList.files?.length != 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files?.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files?[index];
                            String originalFileName = Cf.instance.getFileName(messageList.files![index]);
                            String formattedFileName = Cf.instance.formatFileName(originalFileName);
                            String fileType = Cf.instance.getFileExtension(originalFileName);
                            // IconData fileIcon = getFileIcon(fileType);
                            bool isAudioFile = fileType.toLowerCase() == 'm4a' ||
                                fileType.toLowerCase() == 'mp3' ||
                                fileType.toLowerCase() == 'wav';
                            if (isAudioFile) {
                              print("Rendering Audio Player for: ${ApiString.profileBaseUrl}$filesUrl");
                              return AudioPlayerWidget(
                                audioUrl: filesUrl ?? "",
                                audioPlayers: _audioPlayers,
                                audioDurations: _audioDurations,
                                onPlaybackStart: _handleAudioPlayback,
                                currentlyPlayingPlayer: _currentlyPlayingPlayer,
                                isForwarded: false,
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
                      Visibility(
                        visible: messageList.replies?.isNotEmpty ?? false,
                        child: GestureDetector(
                          onTap: () {
                            print("Simple Passing = ${messageId.toString()}");
                            Cf.instance.pushScreen(screen:
                            ReplyMessageScreenChannel(msgID: messageId.toString(),channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",channelId: channelID,))
                            .then((value) {
                              print("value>>> $value");
                              if (messageList.replies != null && messageList.replies!.isNotEmpty) {
                                for (var reply in messageList.replies!) {
                                  if (!(reply.readBy?.contains(signInModel.data?.user!.id) ?? false) && (reply.isSeen ?? false) == false) {
                                    reply.isSeen = true;
                                    reply.readBy ??= [];
                                    if (!reply.readBy!.contains(signInModel.data!.user!.id!)) {
                                      reply.readBy!.add(signInModel.data!.user!.id!);
                                    }
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
                                              userID: messageList.repliesSenderInfo?[0].id ?? "",
                                              userName: messageList.repliesSenderInfo?[0].username ?? "",
                                              status: "",
                                              needToShowIcon: false,
                                              radius: 12,
                                              otherUserProfile: messageList.repliesSenderInfo?[0].avatarUrl ?? "",
                                            ),
                                            if (messageList.repliesSenderInfo!.length > 1)
                                              Positioned(
                                                left: 16,
                                                child: Cw.instance.profileIconWithStatus(
                                                  userID: messageList.repliesSenderInfo?[1].id ?? "",
                                                  userName: messageList.repliesSenderInfo?[1].username ?? "",
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
                                  // visible: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any(
                                  //  (reply) => !(reply.readBy?.contains(signInModel.data?.user!.id) ?? false) && (reply.isSeen ?? false) == false,),
                                  visible: messageList.replies != null &&
                                      messageList.replies!.isNotEmpty &&
                                      messageList.replies!.any((reply) =>
                                      !(reply.readBy?.contains(signInModel.data?.user!.id) ?? false) &&
                                          (reply.isSeen ?? false) == false),
                                  child: Container(
                                    margin:EdgeInsets.only(right: 5),
                                    width: messageList.replies != null &&
                                        messageList.replies!.isNotEmpty &&
                                        messageList.replies!.any((reply) =>
                                        !(reply.readBy?.contains(signInModel.data?.user!.id) ?? false) &&
                                            (reply.isSeen ?? false) == false)
                                        ? 10 : 0,
                                    height: messageList.replies != null &&
                                        messageList.replies!.isNotEmpty &&
                                        messageList.replies!.any((reply) =>
                                        !(reply.readBy?.contains(signInModel.data?.user!.id) ?? false) &&
                                            (reply.isSeen ?? false) == false)
                                        ? 10 : 0,
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
                                    .map((id) => id as String)
                                    .toSet()
                                    .toList();

                                // Count total unique users for the counter
                                final totalUniqueUsers = uniqueUsers.length;

                                // Get usernames for the visible avatars (show at most 3)
                                final visibleUsers = uniqueUsers.take(3).toList();
                                final remainingUsers = totalUniqueUsers > 2 ? totalUniqueUsers - 2 : 0;

                                // Get usernames for the visible avatars
                                List<String> usernames = [];
                                for (int i = 0; i < visibleUsers.length && i < messageList.reactions!.length; i++) {
                                  String? username = messageList.reactions!
                                      .firstWhere((r) => r.userId == visibleUsers[i],
                                      orElse: () => Message().reactions!.first)
                                      .username;

                                  usernames.add(username ?? "");
                                }

                                // Calculate the width needed based on number of avatars
                                final double stackWidth = visibleUsers.isEmpty ? 0 :
                                (visibleUsers.length == 1 ? 30 :
                                (visibleUsers.length == 2 ? 50 : 70));

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
                                              child: i < 2 || remainingUsers == 0 ?
                                              Cw.instance.profileIconWithStatus(
                                                userID: visibleUsers[i],
                                                userName: i < usernames.length ? usernames[i] : "",
                                                status: "",
                                                needToShowIcon: false,
                                                radius: 14,
                                                otherUserProfile: channelChatProvider.getUserById(visibleUsers[i])?.thumbnailAvatarUrl ?? '',
                                                borderColor: AppColor.blueColor,
                                              ) :
                                              // Last avatar with +X indicator
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  // border: Border.all(color: AppColor.blackColor),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "+$remainingUsers",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
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
                                          context.read<ChannelChatProvider>().reactionRemove(
                                              messageId: messageList.id!,
                                              reactUrl: entry.key,
                                              channelId: channelID,
                                              isFrom: "Channel"
                                          );
                                        } else {
                                          context.read<ChannelChatProvider>().reactMessage(
                                              messageId: messageList.id!,
                                              reactUrl: entry.key,
                                              channelId: channelID,
                                              isFrom: "Channel"
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
                // Spacer(),
                Visibility(
                  visible: !(messageList.isLog ?? false),
                  child: Cw.instance.popMenu2(
                      context,
                      hasAudioFile: (messageList.files?.any((file) {
                        String fileType = Cf.instance.getFileExtension(Cf.instance.getFileName(file));
                        return fileType.toLowerCase() == 'm4a' ||
                            fileType.toLowerCase() == 'mp3' ||
                            fileType.toLowerCase() == 'wav';
                      }) ?? false) ||
                          (messageList.forwards?.files?.any((file) {
                            String fileType = Cf.instance.getFileExtension(Cf.instance.getFileName(file));
                            return fileType.toLowerCase() == 'm4a' ||
                                fileType.toLowerCase() == 'mp3' ||
                                fileType.toLowerCase() == 'wav';
                          }) ?? false),
                      isPinned: pinnedMsg,
                      createdAt: messageList.createdAt.toString(),
                      currentUserId: userId,
                      onOpened: () {},
                      onClosed: () {},
                      onReact: () {
                        Cw.instance.showReactionBar(context, messageId, channelID, "Channel");
                      },
                      isForwarded: messageList.isForwarded! ? false : true,
                      opened: false,
                      onForward: () => Cf.instance.pushScreen(screen: ForwardMessageScreen(userName: messageList.senderInfo?.username ?? 'Unknown',time: Cf.instance.formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: messageList.senderInfo?.avatarUrl ?? '',forwardMsgId: messageId,)),
                      onReply: () => Cf.instance.pushScreen(screen: ReplyMessageScreenChannel(msgID: messageId.toString(),channelName: channelChatProvider.getChannelInfo?.data?.name ?? "",channelId: channelID,)),
                      onPin: () => channelChatProvider.pinUnPinMessage(channelID: channelID, messageId: messageId, pinned: pinnedMsg = !pinnedMsg ),
                      onCopy: () => Cf.instance.copyToClipboard(context, parse(message).body?.text ?? ""),
                      onEdit: () => setState(() {
                        _messageController.clear();
                        FocusScope.of(context).requestFocus(_focusNode);
                        int position = _messageController.text.length;
                        currentUserMessageId = messageId;
                        print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                        _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                      }),
                      onDelete: () => Cw.instance.deleteMessageDialog(context, ()=> Provider.of<ChannelChatProvider>(context,listen: false).deleteMessageFromChannel(messageId: messageId,))
                  ),
                )
              ],
            ),
          ],
        ),
      );
    },);
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
                    final user = Provider.of<ChannelChatProvider>(context, listen: false).getUserById(userId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Cw.instance.profileIconWithStatus(
                            userID: userId,
                            userName: user?.username ?? '',
                            status: "",
                            needToShowIcon: false,
                            radius: 16,
                            otherUserProfile: user?.avatarUrl ?? '',
                            borderColor: AppColor.blueColor,
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
