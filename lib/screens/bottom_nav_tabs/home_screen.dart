import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/screens/browse_and_search_channel/browse_and_search_channel.dart';
import 'package:e_connect/screens/create_channel_screen/create_channel_screen.dart';
import 'package:e_connect/screens/find_channel_screen/find_channel_screen.dart';
import 'package:e_connect/screens/open_direct_message/open_direct_message.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../model/channel_list_model.dart';
import '../../model/direct_message_list_model.dart';
import '../../utils/common/common_function.dart';
import '../chat/single_chat_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final channelListCubit = ChannelListCubit();
  List<OptionItem> options = [
    OptionItem(
      icon: Icons.public,
      title: "Browse Channels",
      onTap: () => pushScreenWithTransition(BrowseAndSearchChannel()),
    ),
    OptionItem(
      icon: Icons.add,
      title: "Create New Channel",
      onTap: () => pushScreenWithTransition(CreateChannelScreen()),
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
    commonCubit.getUserByIDCall();
    channelListCubit.getFavoriteList();
    channelListCubit.getChannelList();
    channelListCubit.getDirectMessageList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: commonCubit,
      builder: (context, state) {
    return Scaffold(
      backgroundColor: AppColor.commonAppColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        appBar: AppBar(
          bottom: PreferredSize(preferredSize: Size(double.infinity, MediaQuery.of(context).size.height *0.1), child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeader(),
                    _buildAddButton()
                  ],
                ),
                _buildSearchField(),
              ],),
          )),
        ),
        body: BlocBuilder(
        bloc: channelListCubit,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _buildExpansionSection(
                    title: "FAVORITES",
                      index: 0,
                      itemCount: _getTotalFavoritesCount(),
                    itemBuilder: (context, index) {
                        final userCount = channelListCubit.favoriteListModel?.data?.chatList?.length ?? 0;

                        if (index < userCount) {
                      final favorite = channelListCubit.favoriteListModel?.data?.chatList?[index];
                      return _buildUserRow(
                              index: 0,
                              muteConversation: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(favorite?.sId ?? "") ?? false,
                              imageUrl: favorite?.thumbnailAvatarUrl ?? "",
                              username: favorite?.username ?? "",
                              status: favorite?.status ?? "",
                              userId: favorite?.sId ?? "",
                              customStatusEmoji: favorite?.customStatusEmoji ?? "",
                              unSeenMsgCount: favorite?.unseenMessagesCount ?? 0,
                              children: [
                                _buildPopupMenuForFavorite(favorite: channelListCubit.favoriteListModel?.data?.chatList?[index]),
                              ]
                          );
                        }
                        else {
                          final channelIndex = index - userCount;
                          final favoriteChannels = channelListCubit.favoriteListModel?.data?.favouriteChannels ?? [];
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
                    itemCount: channelListCubit.channelListModel?.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final channel = channelListCubit.channelListModel!.data![index];
                      return _buildChannelRow(channel);
                    },
                  ),
                    _buildExpansionSection(
                      index: 2,
                    title: "DIRECT MESSAGE",
                    itemCount: channelListCubit.directMessageListModel?.data?.chatList?.length ?? 0,
                    itemBuilder: (context, index) {
                      final directMessage = channelListCubit.directMessageListModel!.data!.chatList?[index];
                      return _buildUserRow(
                            muteConversation: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(directMessage?.sId ?? "") ?? false,
                            index: 2,
                            imageUrl: directMessage?.thumbnailAvatarUrl ?? "",
                        username: directMessage?.username ?? "",
                        status: directMessage?.status ?? "",
                        userId: directMessage?.sId ?? "",
                            customStatusEmoji: directMessage?.customStatusEmoji ?? "",
                            unSeenMsgCount: directMessage?.unseenMessagesCount ?? 0,
                            children: [
                              _buildPopupMenuForDirectMessage(chatLisDirectMessage: channelListCubit.directMessageListModel?.data?.chatList?[index]),
                            ]

                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      );
    },);
  }

  SizedBox _buildPopupMenuForFavorite({ChatList? favorite}) {
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
            channelListCubit.readUnreadMessages(oppositeUserId: favorite.sId ?? "", isCalledForFav: true, isCallForReadMessage: favorite.unseenMessagesCount! > 0 ? true : false);
          } else if (value == "favorite") {
            channelListCubit.removeFromFavorite(favouriteUserId: favorite?.sId ?? "");
          } else if (value == "mute") {
            channelListCubit.muteUser(userIdToMute: favorite?.sId ?? "", isForMute: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(favorite?.sId) ?? false);
          } else if (value == "leave") {
            channelListCubit.closeConversation(conversationUserId: favorite?.sId ?? "", isCalledForFav: true);
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
                    commonCubit.getUserModel?.data?.user!.muteUsers!.contains(favorite.sId) ?? false != true
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_none,
                    size: 20),
                SizedBox(width: 10),
                commonText(
                    text: commonCubit.getUserModel?.data?.user!.muteUsers!
                                .contains(favorite.sId) !=
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
  }
  SizedBox _buildPopupMenuForDirectMessage({ChatListDirectMessage? chatLisDirectMessage}) {
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
            channelListCubit.readUnreadMessages(
                oppositeUserId: chatLisDirectMessage.sId ?? "",
                isCalledForFav: true,
                isCallForReadMessage:
                chatLisDirectMessage.unseenMessagesCount! > 0 ? true : false);
          } else if (value == "favorite") {
            // channelListCubit.removeFromFavorite(favouriteUserId: chatLisDirectMessage?.sId ?? "");
            channelListCubit.addUserToFavorite(favouriteUserId: chatLisDirectMessage?.sId ?? "");
          } else if (value == "mute") {
            channelListCubit.muteUser(
                userIdToMute: chatLisDirectMessage?.sId ?? "",
                isForMute: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(chatLisDirectMessage?.sId) ?? false);
          } else if (value == "leave") {
            channelListCubit.closeConversation(
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
                    commonCubit.getUserModel?.data?.user!.muteUsers!.contains(chatLisDirectMessage.sId) ?? false != true
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_none,
                    size: 20),
                SizedBox(width: 10),
                commonText(
                    text: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(chatLisDirectMessage.sId) != true
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
  }

  SizedBox _buildPopupMenuForFavChannel({FavouriteChannels? favouriteChannels}) {
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
                                  channelListCubit.readUnReadChannelMessage(oppositeUserId: favouriteChannels.sId ?? "",  isCallForReadMessage: favouriteChannels.unseenMessagesCount! > 0 ? true : false);
                                }else if(value == "favorite"){
                                  channelListCubit.removeChannelFromFavorite(favoriteChannelID: favouriteChannels?.sId ?? "");
                                }else if(value == "mute"){
                                  channelListCubit.muteUser(userIdToMute: favouriteChannels?.sId ?? "",isForMute: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(favouriteChannels?.sId) ?? false);
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
                                      Icon(commonCubit.getUserModel?.data?.user!.muteUsers!.contains(favouriteChannels.sId) ?? false != true ? Icons.notifications_off_outlined : Icons.notifications_none, size: 20),
                                      SizedBox(width: 10),
                                      commonText(text: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(favouriteChannels.sId)  != true ? "Mute Conversation" : "Unmute Conversation"),
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
  }
  SizedBox _buildPopupMenuForChannel({ChannelList? channelListModel}) {
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
                                  channelListCubit.readUnReadChannelMessage(oppositeUserId: channelListModel.sId ?? "",  isCallForReadMessage: channelListModel.unreadCount! > 0 ? true : false);
                                }else if(value == "favorite"){
                                  channelListCubit.addChannelToFavorite(channelId: channelListModel?.sId ?? "");
                                }else if(value == "mute"){
                                  channelListCubit.muteUser(userIdToMute: channelListModel?.sId ?? "",isForMute: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(channelListModel?.sId) ?? false);
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
                                      Icon(commonCubit.getUserModel?.data?.user!.muteUsers!.contains(channelListModel.sId) ?? false != true ? Icons.notifications_off_outlined : Icons.notifications_none, size: 20),
                                      SizedBox(width: 10),
                                      commonText(text: commonCubit.getUserModel?.data?.user!.muteUsers!.contains(channelListModel.sId)  != true ? "Mute Conversation" : "Unmute Conversation"),
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
  }

  Future<dynamic> leaveChannelDialog(String? channelId) {
    return showDialog(context: context, builder: (context) {
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
                                                    channelListCubit.leaveChannel(channelId: channelId ?? "");
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
  }



  // Add this widget after _buildHeader
  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.borderColor.withOpacity(0.2),
        ),
      ),
      child: commonTextFormField(controller: TextEditingController(), hintText: "Find Channel",readOnly: true,onTap: () => pushScreenWithTransition(FindChannelScreen()), ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.borderColor.withOpacity(0.1),
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
        color: AppColor.borderColor.withOpacity(0.1),
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
    print("hiiiii>>> ${commonCubit.getUserModel?.data?.user!.muteUsers!.contains(userId)}");
      print("hiiiii>>> ${commonCubit.getUserModel?.data?.user!.muteUsers!}");
      print("hiiiii>>> $userId");
    return Container(
     margin: const EdgeInsets.symmetric(vertical: 6),
     child: InkWell(
       onTap: () => pushScreen(screen: SingleChatMessageScreen(userName: username, oppositeUserId: userId)),
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
             commonText(
               text: username,
               color: Colors.white.withOpacity(0.9),
               fontSize: 14,
               fontWeight: FontWeight.w500,
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
             Visibility(
                 visible: unSeenMsgCount != 0,
                 child: Container(
                   decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(5)
                   ),
                   padding: EdgeInsets.symmetric(vertical: 3,horizontal: 7),
                   margin: EdgeInsets.only(left: 5),
                   child: commonText(text: "$unSeenMsgCount"),
                 )),
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
    // return BlocBuilder<CommonCubit,CommonState>(builder: (context, state) {
    //   // final commonCubit = context.read<CommonCubit>();
    //   print("hiiiii>>> ${commonCubit.getUserModel?.data?.user!.muteUsers!.contains(userId)}");
    //   print("hiiiii>>> ${commonCubit.getUserModel?.data?.user!.muteUsers!}");
    //   print("hiiiii>>> $userId");
    // return
    // },);
    //   margin: const EdgeInsets.symmetric(vertical: 6),
    //   child: InkWell(
    //     onTap: () {
    //       // Handle user row tap
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => SingleChatMessageScreen(
    //                   userName: username,
    //                   oppositeUserId: userId,
    //                 )),
    //       );
    //     },
    //     borderRadius: BorderRadius.circular(8),
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    //       child: Row(
    //         children: [
    //           profileIconWithStatus(
    //             userID: userId,
    //             otherUserProfile: imageUrl,
    //             status: status,
    //           ),
    //           const SizedBox(width: 12),
    //           commonText(
    //             text: username,
    //             color: Colors.white.withOpacity(0.9),
    //             fontSize: 14,
    //             fontWeight: FontWeight.w500,
    //           ),
    //           Visibility(
    //               visible: userId == signInModel.data?.user?.id,
    //               child: Padding(
    //                 padding: const EdgeInsets.only(left: 5.0),
    //                 child: commonText(text: "(you)", color: Colors.white),
    //               )),
    //           Visibility(
    //               visible: customStatusEmoji != "",
    //               child: Padding(
    //                 padding: const EdgeInsets.only(left: 8.0),
    //                 child: CachedNetworkImage(
    //                   imageUrl: customStatusEmoji!,
    //                   height: 20,
    //                   width: 20,
    //                 ),
    //               )),
    //           Visibility(
    //               visible: unSeenMsgCount != 0,
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(5)),
    //                 padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
    //                 margin: EdgeInsets.only(left: 5),
    //                 child: commonText(text: "$unSeenMsgCount"),
    //               ))
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildChannelRow(ChannelList channel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          // Handle channel row tap
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          commonChannelIcon(isPrivate: channel.isPrivate == true ? true : false),
              const SizedBox(width: 12),
              Expanded(
            child: commonText(
              text: channel.name ?? "",
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Visibility(
              visible: channel.unreadCount != 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)
                ),
                padding: EdgeInsets.symmetric(vertical: 3,horizontal: 7),
                margin: EdgeInsets.only(left: 5),
                child: commonText(text: "${channel.unreadCount}"),
              )),
          _buildPopupMenuForChannel(channelListModel: channel,),
            ],
          ),
        ),
      ),
    );
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
  int _getTotalFavoritesCount() {
    final userCount = channelListCubit.favoriteListModel?.data?.chatList?.length ?? 0;
    final channelCount = channelListCubit.favoriteListModel?.data?.favouriteChannels?.length ?? 0;
    return userCount + channelCount;
  }

  // Add new method for favorite channels
  Widget _buildFavoriteChannelRow(FavouriteChannels channel,List<Widget> children) {
    final isPrivate = channel.isPrivate;
    final name = channel.name;
    final unSeenCount = channel.unseenMessagesCount;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          // Handle channel tap
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              commonChannelIcon(isPrivate: isPrivate!),
              const SizedBox(width: 12),
              commonText(
                text: name!,
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Visibility(
                  visible: unSeenCount != 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    padding: EdgeInsets.symmetric(vertical: 3,horizontal: 7),
                    margin: EdgeInsets.only(left: 5),
                    child: commonText(text: "$unSeenCount"),
                  )),
              Spacer(),
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




