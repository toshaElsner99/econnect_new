import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/screens/bottom_nav_tabs/setting_screen.dart';
import 'package:e_connect/screens/browse_and_search_channel/browse_and_search_channel.dart';
import 'package:e_connect/screens/channel/channel_chat_screen.dart';
import 'package:e_connect/screens/create_channel_screen/create_channel_screen.dart';
import 'package:e_connect/screens/find_channel_screen/find_channel_screen.dart';
import 'package:e_connect/screens/open_direct_message/open_direct_message.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/channel_list_model.dart';
import '../../model/direct_message_list_model.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/common_provider.dart';
import '../../socket_io/socket_io.dart';
import '../../utils/app_preference_constants.dart';
import '../../utils/common/common_function.dart';
import '../channel/channel_member_info_screen/channel_members_info.dart';
import '../chat/single_chat_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<OptionItem> options = [
    OptionItem(
      icon: Icons.add,
      title: "Create New Channel",
      onTap: () => pushScreenWithTransition(CreateChannelScreen()),
    ),
    OptionItem(
      icon: Icons.public,
      title: "Browse Channels",
      onTap: () => pushScreenWithTransition(BrowseAndSearchChannel()),
    ),
    OptionItem(
      icon: Icons.message,
      title: "Open a Direct Message",
      onTap: () => pushScreenWithTransition(OpenDirectMessage()),
    ),
  ];
  final Map<String, bool> _isExpanded = {
    'FAVORITES': true,
    'CHANNEL': true,
    'DIRECT MESSAGE': true,
  };
  @override
  void initState() {
    super.initState();
    Provider.of<SocketIoProvider>(context,listen: false).connectSocket();
    Provider.of<CommonProvider>(context,listen: false).getUserByIDCall();
    Provider.of<ChannelListProvider>(context,listen: false).getFavoriteList();
    Provider.of<ChannelListProvider>(context,listen: false).getChannelList();
    Provider.of<ChannelListProvider>(context,listen: false).getDirectMessageList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<CommonProvider>(context,listen: false).getUserByIDCall();
        await Provider.of<ChannelListProvider>(context,listen: false).getFavoriteList();
        await Provider.of<ChannelListProvider>(context,listen: false).getChannelList();
        await Provider.of<ChannelListProvider>(context,listen: false).getDirectMessageList();
      },
      child: Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider, commonProvider, child) {
        return Scaffold(
          backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? null : AppColor.appBarColor,
          floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
          appBar: AppBar(
            bottom: PreferredSize(preferredSize: Size(double.infinity, MediaQuery.of(context).size.height *0.1), child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeader(),
                      Spacer(),
                      buildOpenSetting(),
                      _buildAddButton()
                    ],
                  ),
                  _buildSearchField(),
                ],),
            )),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpansionSection(
                    title: "FAVORITES",
                    index: 0,
                    itemCount: _getTotalFavoritesCount(channelListProvider: channelListProvider),
                    itemBuilder: (context, index) {
                      final userCount = channelListProvider.favoriteListModel?.data?.chatList?.length ?? 0;

                      if (index < userCount) {
                        final favorite = channelListProvider.favoriteListModel?.data?.chatList?[index];
                        return _buildUserRow(
                            index: 0,
                            muteConversation: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(favorite?.sId ?? "") ?? false,
                            imageUrl: favorite?.thumbnailAvatarUrl ?? "",
                            username: favorite?.username ?? "",
                            status: favorite?.status ?? "",
                            userId: favorite?.sId ?? "",
                            customStatusEmoji: favorite?.customStatusEmoji ?? "",
                            unSeenMsgCount: favorite?.unseenMessagesCount,
                            children: [
                              _buildPopupMenuForFavorite(favorite: channelListProvider.favoriteListModel?.data?.chatList?[index]),
                            ]
                        );
                      }
                      else {
                        final channelIndex = index - userCount;
                        final favoriteChannels = channelListProvider.favoriteListModel?.data?.favouriteChannels ?? [];
                        if (channelIndex < favoriteChannels.length) {
                          final favoriteChannel = favoriteChannels[channelIndex] ;
                          return _buildFavoriteChannelRow(favoriteChannel,
                              [
                                _buildPopupMenuForFavChannel(favouriteChannels: favoriteChannels[channelIndex])
                              ]
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  _buildExpansionSection(
                    title: "CHANNEL",
                    index: 1,
                    itemCount: channelListProvider.channelListModel?.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final channel = channelListProvider.channelListModel!.data![index];
                      return _buildChannelRow(channel);
                    },
                  ),
                  _buildExpansionSection(
                    index: 2,
                    title: "DIRECT MESSAGE",
                    itemCount: channelListProvider.directMessageListModel?.data?.chatList?.length ?? 0,
                    itemBuilder: (context, index) {
                      final directMessage = channelListProvider.directMessageListModel?.data?.chatList?[index];
                      return _buildUserRow(
                          muteConversation: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(directMessage?.sId ?? "") ?? false,
                          index: 2,
                          imageUrl: directMessage?.thumbnailAvatarUrl ?? "",
                          username: directMessage?.username ?? "",
                          status: directMessage?.status ?? "",
                          userId: directMessage?.sId ?? "",
                          customStatusEmoji: directMessage?.customStatusEmoji ?? "",
                          unSeenMsgCount: directMessage?.unseenMessagesCount ?? 0,
                          children: [
                            _buildPopupMenuForDirectMessage(chatLisDirectMessage: channelListProvider.directMessageListModel?.data?.chatList?[index]),
                          ]

                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },),
    );
  }

  Container buildOpenSetting() {
    return Container(
                          margin: EdgeInsets.only(right: 7),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.borderColor.withOpacity(0.05),
                          ),
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.settings_suggest_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              onPressed: () => pushScreenWithTransition(SettingScreen())),
                        );
  }

  Widget _buildPopupMenuForFavorite({ChatList? favorite}) {
    return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider,commonProvider, child) {
      return SizedBox(
        height: 20,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 24,color: Colors.white,),
          onSelected: (value) {
            print("Selected: $value");
            if (value == "unread") {
              print("unREADMESSAGE>>>>> ${favorite!.unseenMessagesCount}");
              channelListProvider.readUnreadMessages(oppositeUserId: favorite.sId ?? "", isCalledForFav: true, isCallForReadMessage: favorite.unseenMessagesCount! > 0 ? true : false);
            } else if (value == "favorite") {
              channelListProvider.removeFromFavorite(favouriteUserId: favorite?.sId ?? "");
            } else if (value == "mute") {
              channelListProvider.muteUser(userIdToMute: favorite?.sId ?? "", isForMute: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(favorite?.sId) ?? false);
            } else if (value == "leave") {
              channelListProvider.closeConversation(conversationUserId: favorite?.sId ?? "", isCalledForFav: true);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              height: 35,
              value: "unread",
              child: Row(
                children: [
                  Icon(Icons.mark_chat_unread_outlined, size: 20),
                  SizedBox(width: 10),
                  commonText(
                      text: favorite!.unseenMessagesCount! > 0
                          ? "Mark as read"
                          : "Mark as unread"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "favorite",
              child: Row(
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 10),
                  commonText(text: "Unfavorite"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "mute",
              child: Row(
                children: [
                  Icon(
                      commonProvider.getUserModel?.data?.user?.muteUsers?.contains(favorite.sId) ?? false != true
                          ? Icons.notifications_none
                          : Icons.notifications_off_outlined,
                      size: 20),
                  SizedBox(width: 10),
                  commonText(
                      text: commonProvider.getUserModel?.data?.user!.muteUsers!.contains(favorite.sId) !=
                          true
                          ? "Mute Conversation"
                          : "Unmute Conversation"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "leave",
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    "Close Conversation",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }
  Widget _buildPopupMenuForDirectMessage({ChatListDirectMessage? chatLisDirectMessage}) {
    return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider, commonProvider, child) {
      return SizedBox(
        height: 20,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 24,color: Colors.white,),
          onSelected: (value) {
            print("Selected: $value");
            if (value == "unread") {
              print("unREADMESSAGE>>>>> ${chatLisDirectMessage!.unseenMessagesCount}");
              channelListProvider.readUnreadMessages(
                  oppositeUserId: chatLisDirectMessage.sId ?? "",
                  isCalledForFav: true,
                  isCallForReadMessage:
                  chatLisDirectMessage.unseenMessagesCount! > 0 ? true : false);
            } else if (value == "favorite") {
              channelListProvider.addUserToFavorite(favouriteUserId: chatLisDirectMessage?.sId ?? "");
            } else if (value == "mute") {
              channelListProvider.muteUser(userIdToMute: chatLisDirectMessage?.sId ?? "", isForMute: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(chatLisDirectMessage?.sId) ?? false);
            } else if (value == "leave") {
              channelListProvider.closeConversation(
                  conversationUserId: chatLisDirectMessage?.sId ?? "", isCalledForFav: false);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              height: 35,
              value: "unread",
              child: Row(
                children: [
                  Icon(Icons.mark_chat_unread_outlined, size: 20),
                  SizedBox(width: 10),
                  commonText(
                      text: chatLisDirectMessage!.unseenMessagesCount! > 0
                          ? "Mark as read"
                          : "Mark as unread"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "favorite",
              child: Row(
                children: [
                  Icon(Icons.star_border, size: 20),
                  SizedBox(width: 10),
                  commonText(text: "Favorite"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "mute",
              child: Row(
                children: [
                  Icon(
                      commonProvider.getUserModel?.data?.user?.muteUsers?.contains(chatLisDirectMessage.sId) ?? false != true
                          ? Icons.notifications_none
                          : Icons.notifications_off_outlined,
                      size: 20),
                  SizedBox(width: 10),
                  commonText(
                      text: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(chatLisDirectMessage.sId) != true
                          ? "Mute Conversation"
                          : "Unmute Conversation"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "leave",
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    "Close Conversation",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }

  Widget _buildPopupMenuForFavChannel({FavouriteChannels? favouriteChannels}) {
    return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider, commonProvider, child) {
      return SizedBox(
        height: 20,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 24,color: Colors.white,),
          onSelected: (value) {
            print("Selected: $value");
            if( value == "unread"){
              print("unREADMESSAGE>>>>> ${favouriteChannels!.unseenMessagesCount}");
              channelListProvider.readUnReadChannelMessage(oppositeUserId: favouriteChannels.sId ?? "",  isCallForReadMessage: favouriteChannels.unseenMessagesCount! > 0 ? true : false);
            }else if(value == "favorite"){
              channelListProvider.removeChannelFromFavorite(favoriteChannelID: favouriteChannels?.sId ?? "");
            }else if(value == "mute"){
              channelListProvider.muteUnMuteChannels(channelId: favouriteChannels?.sId ?? "",isMutedChannel: signInModel.data?.user?.muteChannels!.contains(favouriteChannels?.sId ?? "") ?? false);
            }else if(value == "leave"){
              leaveChannelDialog(favouriteChannels?.sId ?? "");
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              height: 35,
              value: "unread",
              child: Row(
                children: [
                  Icon(Icons.mark_chat_unread_outlined, size: 20),
                  SizedBox(width: 10),
                  commonText(text: favouriteChannels!.unseenMessagesCount! > 0 ? "Mark as read" : "Mark as unread"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "favorite",
              child: Row(
                children: [
                  Icon( Icons.star, size: 20),
                  SizedBox(width: 10),
                  commonText(text:"Unfavorite"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "mute",
              child: Row(
                children: [
                  Icon(signInModel.data?.user?.muteChannels!.contains(favouriteChannels.sId) ?? false ? Icons.notifications_none : Icons.notifications_off_outlined, size: 20),
                  SizedBox(width: 10),
                  commonText(text: signInModel.data?.user?.muteChannels!.contains(favouriteChannels.sId) ?? false ? "Unmute Channel" : "Mute Channel" ),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "leave",
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    "Leave Channel",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }
  Widget _buildPopupMenuForChannel({ChannelList? channelListModel}) {
    return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider, commonProvider, child) {
      return SizedBox(
        height: 20,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 24,color: Colors.white,),
          onSelected: (value) {
            print("Selected: $value");
            if( value == "unread"){
              print("unREADMESSAGE>>>>> ${channelListModel!.unreadCount}");
              channelListProvider.readUnReadChannelMessage(oppositeUserId: channelListModel.sId ?? "",  isCallForReadMessage: channelListModel.unreadCount! > 0 ? true : false);
            }else if(value == "favorite"){
              channelListProvider.addChannelToFavorite(channelId: channelListModel?.sId ?? "");
            }else if(value == "mute"){
              channelListProvider.muteUnMuteChannels(channelId: channelListModel?.sId ?? "", isMutedChannel: signInModel.data?.user!.muteChannels!.contains(channelListModel?.sId) ?? false);
            }else if(value == "leave"){
              leaveChannelDialog(channelListModel?.sId ?? "");
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              height: 35,
              value: "unread",
              child: Row(
                children: [
                  Icon(Icons.mark_chat_unread_outlined, size: 20),
                  SizedBox(width: 10),
                  commonText(text: channelListModel!.unreadCount ! > 0 ? "Mark as read" : "Mark as unread"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "favorite",
              child: Row(
                children: [
                  Icon(Icons.star_border, size: 20),
                  SizedBox(width: 10),
                  commonText(text:"Favorite"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "mute",
              child: Row(
                children: [
                  Icon(signInModel.data?.user!.muteChannels!.contains(channelListModel.sId) ?? false ? Icons.notifications_none : Icons.notifications_off_outlined , size: 20),
                  SizedBox(width: 10),
                  commonText(text: signInModel.data?.user!.muteChannels!.contains(channelListModel.sId) ?? false ? "Unmute Channel" : "Mute Channel"),
                ],
              ),
            ),
            PopupMenuItem(
              height: 35,
              value: "leave",
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    "Leave Channel",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },);
  }

  Future<dynamic> leaveChannelDialog(String? channelId) {
    return showDialog(context: context, builder: (context) {
                                  return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider, commonProvider, child) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      insetPadding: EdgeInsets.zero,
                                      content: Container(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              color: AppColor.commonAppColor,
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  commonText(text: "Confirm Leave Channel",color: Colors.white),
                                                  GestureDetector(
                                                      onTap: () => pop(),
                                                      child: Icon(Icons.close,color: Colors.white,)),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
                                              child: commonText(text: "Are you sure you want to Leave this Channel?"),
                                            ),
                                            Divider(),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => pop(),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: Colors.grey.withOpacity(0.1)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                      child: commonText(text: "Cancel"),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      pop();
                                                      channelListProvider.leaveChannel(channelId: channelId ?? "");
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(left: 10),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: AppColor.redColor,
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                      child: commonText(text: "Leave",color: Colors.white),
                                                    ),
                                                  ),
                                                ],),
                                            )
                                          ],

                                        ),
                                      ),
                                    );
                                  },);
                                },);
  }



  // Add this widget after _buildHeader
  Widget _buildSearchField() {
    return GestureDetector(
      onTap: () => pushScreenWithTransition(FindChannelScreen()),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.borderColor.withOpacity(0.05),
          // borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(CupertinoIcons.search,color: Colors.white,),
          SizedBox(width: 10),
          commonText(text: "Find Channel",color: Colors.white)
        ],),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.borderColor.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
          Image.asset(AppImage.eCLogo, width: 30, height: 30),
        commonText(
          text: AppString.connect,
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ],
      ),
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    Widget? trailing = const SizedBox.shrink(),
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.borderColor.withOpacity(0.05),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
      dense: true,
          maintainState: true,
          initiallyExpanded: _isExpanded[title] ?? false,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded[title] = expanded);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          leading: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isExpanded[title] ?? false ? 0.25 : 0,
            child: Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
          ),
          title: commonText(
            text: title,
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          trailing: trailing,
          children: [
            Column(
              children: List.generate(itemCount, (index) => itemBuilder(context, index)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAddButton() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.borderColor.withOpacity(0.05),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          CupertinoIcons.plus,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        onPressed: () {
          showOptionsBottomSheet(context: context, options: options);
        },
      ),
    );
  }

  Widget _buildUserRow({
    required int index,
    required String imageUrl,
    required String username,
    required String status,
    required String userId,
    required bool muteConversation,
    String? customStatusEmoji = "",
    int? unSeenMsgCount = 0,
    List<Widget>? children,
  }) {
    return Container(
     color: muteConversation ? AppColor.borderColor.withOpacity(0.05) : null,
     margin: const EdgeInsets.symmetric(vertical: 6),
     child: InkWell(
       onTap: () => pushScreen(screen: SingleChatMessageScreen(userName: username, oppositeUserId: userId,calledForFavorite: true,)),
       // onTap: () => pushScreen(screen: ChatScreen(userName: username, oppositeUserId: userId,calledForFavorite: true,)),
       borderRadius: BorderRadius.circular(8),
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          profileIconWithStatus(
            userID: userId,
            otherUserProfile: imageUrl,
            status: status,
          ),
             const SizedBox(width: 12),
             ConstrainedBox(
               constraints: BoxConstraints(minWidth: 0,maxWidth:MediaQuery.of(context).size.width * 0.5),
               child: commonText(
                 text: username,
                 color: Colors.white.withOpacity(0.9),
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
               ),
             ),
             Visibility(
                 visible: userId == signInModel.data?.user?.id,
                 child: Padding(
                   padding: const EdgeInsets.only(left: 5.0),
                   child: commonText(text: "(you)",color: Colors.white),
                 )),
             Visibility(
                 visible: customStatusEmoji != "",
                 child: Padding(
                   padding: const EdgeInsets.only(left: 8.0),
                   child: CachedNetworkImage(imageUrl: customStatusEmoji!,height: 20,width: 20,),
                 )),
             countMsgContainer(unSeenMsgCount ?? 0),
             Spacer(),
             Visibility(
                 visible: muteConversation,
                 child: Image.asset(AppImage.muteNotification,height: 20,width: 20,color: Colors.white,)),
             ...?children,
           ],
         ),
       ),
     ),
       );
  }

  Widget _buildChannelRow(ChannelList channel) {
    print("channelID _buildChannelRow >>> ${channel.sId}");
    return Container(
      color: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false ? AppColor.borderColor.withOpacity(0.05) : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          print("Channel Tapped");
          pushScreen(screen: ChannelChatScreen(channelId: channel.sId ?? "", /*channelName: channel.name!*/));
          },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          commonChannelIcon(isPrivate: channel.isPrivate == true ? true : false),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 0,maxWidth:MediaQuery.of(context).size.width * 0.5),
            child: commonText(
              text: channel.name ?? "",
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          countMsgContainer(channel.unreadCount ?? 0),
              Spacer(),
              Visibility(
                  visible: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false,
                  child: Image.asset(AppImage.muteNotification,height: 20,width: 20,color: Colors.white,)),
              _buildPopupMenuForChannel(channelListModel: channel,),
            ],
          ),
        ),
      ),
    );
  }

  Visibility countMsgContainer(int count) {
    return Visibility(
            visible: count != 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5)
              ),
              padding: EdgeInsets.symmetric(vertical: 3,horizontal: 7),
              margin: EdgeInsets.only(left: 5),
              child: commonText(text: "$count",color: Colors.black),
            ));
  }

  void showOptionsBottomSheet({
    required BuildContext context,
    required List<OptionItem> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bottom sheet indicator
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            ...options.map((option) => _buildOptionItem(option)).toList(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(OptionItem option) {
    return InkWell(
      onTap: () {
        pop();
        option.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: Colors.grey[800],
              size: 24,
            ),
            const SizedBox(width: 16),
            commonText(
              text: option.title,
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  // Add helper method to get total count
  int _getTotalFavoritesCount({required ChannelListProvider channelListProvider}) {
    final userCount = channelListProvider.favoriteListModel?.data?.chatList?.length ?? 0;
    final channelCount = channelListProvider.favoriteListModel?.data?.favouriteChannels?.length ?? 0;
    return userCount + channelCount;
  }

  // Add new method for favorite channels
  Widget _buildFavoriteChannelRow(FavouriteChannels channel,List<Widget> children) {
    final isPrivate = channel.isPrivate;
    final name = channel.name;
    final unSeenCount = channel.unseenMessagesCount;
    // final muteChannel = ;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false ? AppColor.borderColor.withOpacity(0.05) : null,
      child: InkWell(
        onTap: ()=> pushScreen(screen: ChannelChatScreen(channelId: channel.sId!, /*channelName: channel.name!*/)),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              commonChannelIcon(isPrivate: isPrivate!),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 0,maxWidth:MediaQuery.of(context).size.width * 0.5),
                child: commonText(
                  text: name!,
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              countMsgContainer(unSeenCount ?? 0),

              Spacer(),
              Visibility(
                  visible: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false,
                  child: Image.asset(AppImage.muteNotification,height: 20,width: 20,color: Colors.white,)),
              ...children,
            ],
          ),
        ),
      ),
    );
  }


}

class OptionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  OptionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}




