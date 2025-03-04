
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
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/browse_and_search_channel_model.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/common_provider.dart';
import '../../screens/chat/media_preview_screen.dart';
import '../../widgets/chat_profile_header.dart';


/// ///


class SingleChatMessageScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  final bool? calledForFavorite;
  final bool? needToCallAddMessage;
  // final bool callForReadMsg;

  const SingleChatMessageScreen({super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite, this.needToCallAddMessage});

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
  int? _selectedIndex;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showMentionList = false;
  int _mentionCursorPosition = 0;
  final TextEditingController _messageController = TextEditingController();


  void _onTextChanged() {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;

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
         oppositeUserId: widget.oppositeUserId,
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

    // Handle both Users object and special mention map
    String mentionText;
    if (user is Users) {
      mentionText = '@${user.username} ';
    } else if (user is Map<String, dynamic>) {
      mentionText = '@${user['username']} ';
    } else if (user is User) {
      mentionText = '@${user.username} ';
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


  List<dynamic> _getFilteredUsers(String? searchQuery, CommonProvider provider) {
    // Show initial users (current user and recipient)
    final List<User> initialUsers = [];
    final currentUser = userCache[signInModel.data?.user?.id];
    final recipientUser = userCache[widget.oppositeUserId];

    if (searchQuery?.isEmpty ?? true) {
      if (currentUser?.data?.user != null) {
        initialUsers.add(currentUser.data.user);
      }
      if (recipientUser?.data?.user != null && widget.oppositeUserId != signInModel.data?.user?.id) {
        initialUsers.add(recipientUser.data.user);
      }
      return initialUsers;
    }

    // Filter users from getUserMentionModel based on search
    final allUsers = provider.getUserMentionModel?.data?.users ?? [];
    final query = searchQuery!.toLowerCase();

    // First add matching initial users
    if (currentUser?.data?.user != null &&
        ((currentUser.data.user.username?.toLowerCase().contains(query) ?? false) ||
            (currentUser.data.user.fullName?.toLowerCase().contains(query) ?? false))) {
      initialUsers.add(currentUser.data.user);
    }
    if (recipientUser?.data?.user != null &&
        widget.oppositeUserId != signInModel.data?.user?.id &&
        ((recipientUser.data.user.username?.toLowerCase().contains(query) ?? false) ||
            (recipientUser.data.user.fullName?.toLowerCase().contains(query) ?? false))) {
      initialUsers.add(recipientUser.data.user);
    }

    // Then add other matching users
    final otherUsers = allUsers.where((user) =>
    ((user.username?.toLowerCase().contains(query) ?? false) ||
        (user.fullName?.toLowerCase().contains(query) ?? false)) &&
        user.sId != signInModel.data?.user?.id &&
        user.sId != widget.oppositeUserId
    ).toList();

    return [...initialUsers, ...otherUsers];
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("oppositeUserId in init==> ${widget.oppositeUserId}");
      /// this is for pagination ///
      Provider.of<ChatProvider>(context,listen: false).pagination(oppositeUserId: widget.oppositeUserId);
      commonProvider.updateStatusCall(status: "online");
      /// opposite user typing listen ///
      chatProvider.getTypingUpdate();
      /// THis Is Socket Listening Event ///
      socketProvider.listenSingleChatScreen(oppositeUserId: widget.oppositeUserId);
      /// THis is Doing for update pin message and get Message List ///
      socketProvider.socketListenPinMessage(oppositeUserId: widget.oppositeUserId,callFun: (){
        chatProvider.getMessagesList(oppositeUserId: widget.oppositeUserId,currentPage: 1,isFromMsgListen: true);
        // fetchOppositeUserDetails();
      });
      /// this for add user to chat list on home screen 3rd Expansion tiles ///
      if(widget.needToCallAddMessage == true){
        channelListProvider.addUserToChatList(selectedUserId: widget.oppositeUserId);
      }
      // chatProvider.getFileListingInChat(oppositeUserId: widget.oppositeUserId);
      /// this is for read message ///
      channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
      /// this is default call with page 1 for chat listing ///
      chatProvider.getMessagesList(oppositeUserId: widget.oppositeUserId,currentPage: 1,);
      /// this is for fetch other user details and store it to cache memory ///
      _fetchAndCacheUserDetails();
      /// this is for get user mention listing api ///
      commonProvider.getUserApi(id: widget.oppositeUserId);
    },);
    _messageController.addListener(_onTextChanged);
  }

  void fetchOppositeUserDetails()async{
    userDetails = await commonProvider.getUserByIDCallForSecondUser(userId: widget.oppositeUserId);
  }
  void _fetchAndCacheUserDetails() async {
    userDetails = await commonProvider.getUserByIDCallForSecondUser(userId: widget.oppositeUserId);
    // await commonProvider.getUserByIDCallForSecondUser(userId: signInModel.data!.user!.id);
    setState(()  {
      userCache["${commonProvider.getUserModelSecondUser?.data!.user!.sId}"] = commonProvider.getUserModelSecondUser!;
      userCache["${commonProvider.getUserModel?.data!.user!.sId}"] = commonProvider.getUserModel!;
    });
    print("user>>>>>> ${userCache}");
    print("user>>>>>> ${userDetails?.data!.user!.username}");
    print("user>>>>>> ${commonProvider.getUserModelSecondUser?.data!.user!.username}");
    print("user>>>>>> ${commonProvider.getUserModelSecondUser?.data!.user!.sId}");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonProvider,ChatProvider>(builder: (context, commonProvider,chatProvider, child) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
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
                Expanded(child: Center(child: ChatProfileHeader(userName: userDetails?.data?.user?.fullName ?? userDetails?.data?.user?.username ?? 'Unknown', userImageUrl: ApiString.profileBaseUrl + (userDetails?.data?.user?.avatarUrl ?? ''),))),
                }else...{
                  Expanded(
                    child: ListView(
                      controller: chatProvider.scrollController,
                      reverse: true,
                      children: [
                        dateHeaders(),
                      ],
                    ),
                  ),
                },
                if(userDetails?.data?.user?.isLeft == false)...{
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
              }
            ],
          ),
        ),
      );
    },);
  }
  AppBar buildAppBar(CommonProvider commonProvider, ChatProvider chatProvider) {
    return AppBar(
      toolbarHeight: 60,
      // leadingWidth: 35,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: IconButton(icon: Icon(CupertinoIcons.back,color: Colors.white,),color: Colors.white, onPressed: () {
          pop();
          channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
        },),
      ),
      titleSpacing: 0,
      title:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: commonText(
                  text: widget.userName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              Visibility(
                visible: userDetails?.data?.user?.isFavourite ?? false,
                child: Icon(Icons.star_rate_rounded, color: Colors.yellow, size: 18),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                getCommonStatusIcons(
                  size: 15,
                  status: userDetails?.data?.user?.status ?? "offline",
                  assetIcon: false,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: commonText(
                    text: (userDetails?.data!.user!.sId == chatProvider.oppUserIdForTyping && chatProvider.msgLength == 1)
                        ? "Typing..."
                        : getLastOnlineStatus(
                      userDetails?.data?.user?.status ?? ".....",
                      userDetails?.data?.user!.lastActiveTime,
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
                  visible: userDetails?.data?.user?.customStatusEmoji != null && userDetails?.data?.user?.customStatusEmoji!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: userDetails?.data?.user!.customStatusEmoji ?? "",
                      height: 20,
                      width: 20,
                      errorWidget: (context, url, error) => Icon(Icons.error, size: 20), // Handle image errors
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => pushScreen(screen: PinnedPostsScreen(userName: widget.userName, oppositeUserId: widget.oppositeUserId,userCache: userCache,)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      commonText(
                        text: "${userDetails?.data?.user!.pinnedMessageCount ?? 0}",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      Image.asset(AppImage.pinIcon, height: 15, width: 18, color: Colors.white),
                      const SizedBox(width: 4),
                  ],),
                ),
                GestureDetector(
                    onTap: () => pushScreen(screen: FilesListingScreen(userName: widget.userName,oppositeUserId: widget.oppositeUserId,)),
                    child: Image.asset(AppImage.fileIcon, height: 15, width: 15, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
          onPressed: () {
            showChatSettingsBottomSheet(userId: widget.oppositeUserId);
          },
        ),
      ],
    );
  }

  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _messageController.clear();
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _removeMentionOverlay();
    super.dispose();
  }

  // Widget inputTextFieldWithEditor() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
  //       border: Border(
  //         top: BorderSide(
  //           color: Colors.grey.shade800,
  //           width: 0.5,
  //         ),
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         if (_showToolbar)
  //           Container(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: quill.QuillToolbar.simple(
  //               configurations: quill.QuillSimpleToolbarConfigurations(
  //                   controller: _controller,
  //                   sharedConfigurations: const quill.QuillSharedConfigurations(
  //                     locale: Locale('en'),
  //                   ),
  //                   showDividers: false,
  //                   showFontFamily: false,
  //                   showFontSize: false,
  //                   showBoldButton: true,
  //                   showItalicButton: true,
  //                   showUnderLineButton: false,
  //                   showStrikeThrough: true,
  //                   showInlineCode: true,
  //                   showColorButton: false,
  //                   showBackgroundColorButton: false,
  //                   showClearFormat: false,
  //                   showAlignmentButtons: false,
  //                   showLeftAlignment: false,
  //                   showCenterAlignment: false,
  //                   showRightAlignment: false,
  //                   showJustifyAlignment: false,
  //                   showHeaderStyle: true,
  //                   showListNumbers: true,
  //                   showListBullets: true,
  //                   showListCheck: false,
  //                   showCodeBlock: true,
  //                   showQuote: true,
  //                   showIndent: false,
  //                   showLink: true,
  //                   showUndo: false,
  //                   showRedo: false,
  //                   showSearchButton: false,
  //                   showClipboardCut: false,
  //                   showClipboardCopy: false,
  //                   showClipboardPaste: false,
  //                   multiRowsDisplay: false,
  //                   showSubscript: false,
  //                   showSuperscript: false),
  //             ),
  //           ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           child: Row(
  //             children: [
  //               IconButton(
  //                 icon: Icon(
  //                   Icons.edit,
  //                   color: _showToolbar ? Colors.blue : AppColor.whiteColor,
  //                 ),
  //                 onPressed: () {
  //                   setState(() {
  //                     _showToolbar = !_showToolbar;
  //                   });
  //                 },
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade900,
  //                     borderRadius: BorderRadius.circular(25),
  //                   ),
  //                   child: quill.QuillEditor(
  //                       controller: _controller,
  //                       focusNode: _focusNode,
  //                       scrollController: ScrollController(),
  //                       configurations: quill.QuillEditorConfigurations(
  //                         scrollable: true,
  //                         autoFocus: false,
  //                         checkBoxReadOnly: false,
  //                         placeholder: 'Write to ${userDetails?.data?.user!.username ?? userDetails?.data?.user!.fullName ?? "...."}',
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 8,
  //                         ),
  //                         maxHeight: 100,
  //                         minHeight: 40,
  //                         customStyles: const quill.DefaultStyles(
  //                           paragraph: quill.DefaultTextBlockStyle(
  //                               TextStyle(
  //                                 color: AppColor.whiteColor,
  //                                 fontSize: 16,
  //                               ),
  //                               quill.HorizontalSpacing.zero,
  //                               quill.VerticalSpacing.zero,
  //                               quill.VerticalSpacing.zero,
  //                               BoxDecoration(color: Colors.transparent)),
  //                           placeHolder: quill.DefaultTextBlockStyle(
  //                               TextStyle(
  //                                 color: Colors.grey,
  //                                 fontSize: 16,
  //                               ),
  //                               quill.HorizontalSpacing.zero,
  //                               quill.VerticalSpacing.zero,
  //                               quill.VerticalSpacing.zero,
  //                               BoxDecoration(color: Colors.transparent)),
  //                           quote: quill.DefaultTextBlockStyle(
  //                             TextStyle(
  //                               color: AppColor.whiteColor,
  //                               fontSize: 16,
  //                             ),
  //                             quill.HorizontalSpacing(16, 0),
  //                             quill.VerticalSpacing(8, 0),
  //                             quill.VerticalSpacing(8, 0),
  //                             BoxDecoration(
  //                               border: Border(
  //                                 left: BorderSide(
  //                                   color: AppColor.whiteColor,
  //                                   width: 4,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       )),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         selectedFilesWidget(),
  //         fileSelectionAndSendButtonRow()
  //       ],
  //     ),
  //   );
  // }
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
                                hintText: 'Write to ${userDetails?.data?.user!.username ?? userDetails?.data?.user!.fullName ?? "...."}',
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
                          final filesOfList = await chatProvider.uploadFiles();
                          chatProvider.sendMessage(content: plainText, receiverId: widget.oppositeUserId, files: filesOfList);
                        } else {
                          chatProvider.sendMessage(content: plainText, receiverId: widget.oppositeUserId, editMsgID: currentUserMessageId).then((value) => setState(() {
                            currentUserMessageId = "";
                          }));
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
              return ChatProfileHeader(userName: userDetails?.data?.user?.fullName ?? userDetails?.data?.user?.username ?? 'Unknown', userImageUrl: ApiString.profileBaseUrl + (userDetails?.data?.user?.avatarUrl ?? ''),);
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
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      // if (!userCache.containsKey(userId) && commonProvider.getUserModel!.data!.user!.sId! == userId) {
      //   commonProvider.getUserByIDCall2(userId: userId);
      //   userCache[userId] = commonProvider.getUserModel!;
      // }
      final user = userCache[userId];
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
                    child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "${user?.data!.user!.status}",otherUserProfile: user?.data!.user!.avatarUrl ?? '',radius: 17),
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
                        Wrap(
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
                                  profileIconWithStatus(userID: messageList.senderOfForward?.id ?? "", status: messageList.senderOfForward?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.senderOfForward?.avatarUrl),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        commonText(text: "${messageList.senderOfForward?.username}"),
                                        SizedBox(height: 3),
                                        commonText(text: formatDateString("${messageList.senderOfForward?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                      ],
                                    ),
                                  ),
                                ],),
                              ),
                                commonHTMLText(message: "${messageList.forwardInfo?.content}"),
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
                                                otherUserProfile: messageList.repliesSenderInfo![0].avatarUrl,
                                              ),
                                              if (messageList.repliesSenderInfo!.length > 1)
                                                Positioned(
                                                  left: 16,
                                                  child: profileIconWithStatus(
                                                    userID: messageList.repliesSenderInfo![1].id,
                                                    status: "",
                                                    needToShowIcon: false,
                                                    radius: 12,
                                                    otherUserProfile: messageList.repliesSenderInfo![1].avatarUrl,
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
                    onOpened: () =>  setState(() => _selectedIndex = index),
                    onClosed: () =>  setState(() => _selectedIndex = null),
                    isForwarded: messageList.isForwarded! ? false : true,
                    opened: index == _selectedIndex ? true : false,
                    createdAt: messageList.createdAt!,
                    currentUserId: userId,
                    onForward: ()=> pushScreen(screen: ForwardMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',time: formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: user?.data!.user!.avatarUrl ?? '',forwardMsgId: messageId,)),
                    onReply: () {
                      print("onReply Passing = ${messageId.toString()}");
                    pushScreen(screen: ReplyMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', messageId: messageId.toString(),receiverId: widget.oppositeUserId,));
                    },
                    onPin: () => chatProvider.pinUnPinMessage(receiverId: widget.oppositeUserId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg ),
                    onCopy: () => copyToClipboard(context, message),
                    // onEdit: () => setState(() {
                    //   int position = _controller.document.length - 1;
                    //   currentUserMessageId = messageId;
                    //   print("currentMessageId>>>>> $currentUserMessageId && 67b6d585d75f40cdb09398f5");
                    //   _controller.document.insert(position, message.toString());
                    //   _controller.updateSelection(
                    //     TextSelection.collapsed(offset: _controller.document.length),
                    //     quill.ChangeSource.local,
                    //   );
                    // }),
                      onEdit: ()=> setState(() {
                      int position = _messageController.text.length;
                      currentUserMessageId = messageId;
                      print("currentMessageId>>>>> $currentUserMessageId && 67b6d585d75f40cdb09398f5");
                       _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                      }),
                    onDelete: () => chatProvider.deleteMessage(messageId: messageId.toString(), receiverId: widget.oppositeUserId)),
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

