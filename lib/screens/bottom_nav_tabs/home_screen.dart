import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/favorite_list_model.dart';
import 'package:e_connect/model/direct_message_list_model.dart';
import 'package:e_connect/model/channel_list_model.dart';
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
import '../../notificationServices/pushNotificationService.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/common_provider.dart';
import '../../socket_io/socket_io.dart';
import '../../utils/app_preference_constants.dart';
import '../../utils/common/common_function.dart';
import '../../utils/common/prefrance_function.dart';
import '../chat/single_chat_message_screen.dart';

class HomeScreen extends StatefulWidget  {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin/*, WidgetsBindingObserver */{
  List<OptionItem> options = [
    OptionItem(
      icon: Icons.add,
      title: "Create New Channel",
      onTap: () => pushScreen(screen: CreateChannelScreen()),
    ),
    OptionItem(
      icon: Icons.public,
      title: "Browse Channels",
      onTap: () => pushScreen(screen:BrowseAndSearchChannel()),
    ),
    OptionItem(
      icon: Icons.message,
      title: "Open a Direct Message",
      onTap: () => pushScreen(screen:OpenDirectMessage()),
    ),
  ];
  final Map<String, bool> _isExpanded = {
    'FAVORITES': true,
    'CHANNEL': true,
    'DIRECT MESSAGE': true,
  };
  bool _isInitialized = false;
  
  // Selected tab index
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['All', 'Channels', 'Favourites'];
  
  // PageController for swiping between tabs
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    print("signInModel>>>> ${signInModel.data?.user?.muteChannels}");
    _pageController = PageController(initialPage: _selectedTabIndex);
    // WidgetsBinding.instance.addObserver(this);
    Provider.of<CommonProvider>(context, listen: false).updateStatusCall(status: "online");

    Provider.of<SocketIoProvider>(context,listen: false).connectSocket();
    if(!_isInitialized) {
      Provider.of<CommonProvider>(context,listen: false).getUserByIDCall();
      Provider.of<ChannelListProvider>(context,listen: false).refreshAllLists();
    }
    getFCM();
    Future.delayed(Duration(seconds: 5),(){
      setBadge();
    });
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Provider.of<ChannelListProvider>(context,listen: false).refreshAllLists();
      // Provider.of<SocketIoProvider>(context, listen: false).connectSocket(true);
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  getFCM() async{
   String fcmToken = await getData(AppPreferenceConstants.fcmToken);
   print("fcmToken => $fcmToken");
  }

  setBadge() async{
    await NotificationService.setBadgeCount();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider, commonProvider, child) {
      setBadge();
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<ChannelListProvider>(context,listen: false).refreshAllLists();
            await Provider.of<CommonProvider>(context,listen: false).getUserByIDCall();
          },
          child: Scaffold(
            backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? null : AppColor.appBarColor,
            appBar: AppBar(toolbarHeight: 0,),
            body: Column(
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  child: Row(
                    children: [
                      _buildHeader(),
                      Spacer(),
                      _buildAddButton()
                    ],
                  ),
                ),
                // Search and tabs section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      _buildSearchField(),
                      _buildTabsSection(),
                    ],
                  ),
                ),
                // Content section
                Expanded(child: _buildScreenContent(channelListProvider, commonProvider)),
              ],
            ),
          ),
        ),
      );
    },);
  }

  // Custom tabs widget
  Widget _buildTabsSection() {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: List.generate(
          _tabTitles.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < _tabTitles.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                  _pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _tabTitles[index] == 'All' ? 16 : 20, 
                  vertical: 10
                ),
                decoration: BoxDecoration(
                  border: _selectedTabIndex == index ? null : Border.all(color: AppColor.borderColor,width: 0.2),
                  color: _selectedTabIndex == index 
                      ? AppColor.white
                      : AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : AppColor.blueColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: commonText(
                 text: _tabTitles[index],
                    color: _selectedTabIndex != index
                        ? AppColor.white
                        : AppColor.blueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Content based on selected tab
  Widget _buildScreenContent(ChannelListProvider channelListProvider, CommonProvider commonProvider) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      children: [
        _buildAllTab(channelListProvider, commonProvider),
        _buildChannelsTab(channelListProvider, commonProvider),
        _buildFavoritesTab(channelListProvider, commonProvider),
      ],
    );
  }
  
  // All tab
  Widget _buildAllTab(ChannelListProvider channelListProvider, CommonProvider commonProvider) {
    return channelListProvider.combinedAllItems.isEmpty
      ? Center(
          child: CircularProgressIndicator(
            color: AppColor.blueColor,
          ),
        )
      : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                            color: AppColor.white.withAlpha(15)
                        ),
                      );
                    },
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: channelListProvider.combinedAllItems.length,
                    itemBuilder: (context, index) {
                      final item = channelListProvider.combinedAllItems[index];
                      return _buildListItem(item, commonProvider);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
  }
  
  // Channels tab
  Widget _buildChannelsTab(ChannelListProvider channelListProvider, CommonProvider commonProvider) {
    // Extract channels from combinedAllItems to maintain timestamp sorting
    final channelItems = channelListProvider.combinedAllItems
        .where((item) => item['type'] == 'channel' || item['type'] == 'favoriteChannel')
        .toList();
    
    if (channelItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Channels View",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Your channels will appear here",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                    color: AppColor.white.withAlpha(15)
                ),
              );
            },
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: channelItems.length,
            itemBuilder: (context, index) {
              final item = channelItems[index];
              return _buildListItem(item, commonProvider);
            },
          ),
        ),
      ),
    );
  }

  Container buildOpenSetting() {
    return Container(
      height: 35,
      width: 35,
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.borderColor.withOpacity(0.05),
      ),
      child: IconButton(
        constraints: BoxConstraints(),
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.settings_suggest_rounded,
          color: Colors.white,
          size: 25,
        ),
        onPressed: () => pushScreen(screen: SettingScreen()).then((value) async{
          await Provider.of<CommonProvider>(context,listen: false).getUserByIDCall();
          await Provider.of<ChannelListProvider>(context,listen: false).refreshAllLists();
        },),
      ),
    );
  }


  Widget _buildPopupMenuForFavorite({ChatList? favorite}) {
    return Consumer2<ChannelListProvider,CommonProvider>(builder: (context, channelListProvider,commonProvider, child) {
      return SizedBox(
        height: 30,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 25,color: Colors.white,),
          // offset: Offset(0, 10),
          onSelected: (value) {
            print("Selected: $value");
            if (value == "unread") {
              // print("unREADMESSAGE>>>>> ${favorite!.unseenMessagesCount}");
              channelListProvider.readUnreadMessages(oppositeUserId: favorite?.sId ?? "", isCalledForFav: true, isCallForReadMessage: (favorite?.unseenMessagesCount ?? 0) > 0 ? true : false);
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
                      text: (favorite?.unseenMessagesCount ?? 0) > 0
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
                      commonProvider.getUserModel?.data?.user?.muteUsers?.contains(favorite?.sId) ?? false != true
                          ? Icons.notifications_none
                          : Icons.notifications_off_outlined,
                      size: 20),
                  SizedBox(width: 10),
                  commonText(
                      text: commonProvider.getUserModel?.data?.user!.muteUsers!.contains(favorite?.sId) !=
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
                  commonText(text: "Close Conversation", color: Colors.red,),
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
        height: 30,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 25,color: Colors.white,),
          onSelected: (value) {
            print("Selected: $value");
            if (value == "unread") {
              // print("unREADMESSAGE>>>>> ${chatLisDirectMessage!.unseenMessagesCount}");
              channelListProvider.readUnreadMessages(
                  oppositeUserId: chatLisDirectMessage?.sId ?? "",
                  isCalledForFav: true,
                  isCallForReadMessage:
                  (chatLisDirectMessage?.unseenMessagesCount ?? 0) > 0 ? true : false);
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
                  commonText(text: "Close Conversation", color: Colors.red),
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
        height: 30,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 25,color: Colors.white,),
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
                  commonText(text: "Leave Channel", color: Colors.red),
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
        height: 30,
        width: 30,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 150),
          icon: Icon(Icons.more_vert, size: 25,color: Colors.white,),
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
                  commonText(text: "Leave Channel", color: Colors.red),
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
                                        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.black : Colors.white,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              color: AppPreferenceConstants.themeModeBoolValueGet ? CupertinoColors.darkBackgroundGray : AppColor.commonAppColor,
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
      onTap: () => pushScreen(screen:FindChannelScreen()),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.borderColor.withOpacity(0.05),
          // borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(CupertinoIcons.search,
            color: AppColor.white,size: 20),
          SizedBox(width: 10),
          commonText(text: "Search...",color: AppColor.white,fontWeight: FontWeight.w400)
        ],),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: userHeader()
    );
  }

  userHeader(){
    return Consumer<CommonProvider>(
      builder: (context, commonProvider, _) {
        return GestureDetector(
          onTap: () => openSettings(),
          child: Row(
            children: [
              // User profile image
              profileIconWithStatus(
                  userID: commonProvider.getUserModel?.data?.user?.sId ?? "",
                  status: commonProvider.getUserModel?.data?.user?.status ?? "offline",
                  otherUserProfile: commonProvider.getUserModel?.data?.user?.thumbnailAvatarUrl ?? '',
                  radius: 17,
                  needToShowIcon: true,
                  borderColor: AppColor.blueColor,
                  onTap: () => openSettings(),
                  userName: commonProvider.getUserModel?.data?.user?.username ??  commonProvider.getUserModel?.data?.user?.fullName ?? ""
              ),
              SizedBox(width: 12),
              // User name and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      commonText(
                        text: (commonProvider.getUserModel?.data?.user?.fullName ?? commonProvider.getUserModel?.data?.user?.username ?? ""),
                          color: AppColor.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: commonProvider.getUserModel?.data?.user?.customStatusEmoji != null &&
                        commonProvider.getUserModel?.data?.user?.customStatusEmoji != "",
                        child: CachedNetworkImage(imageUrl: (commonProvider.getUserModel?.data?.user?.customStatusEmoji ?? ""),
                        width: 20),
                      )
                    ],
                  ),
                  if ((commonProvider.getUserModel?.data?.user?.customStatus ?? "").isNotEmpty) ...[
                    SizedBox(height: 4),
                    commonText(
                      text: commonProvider.getUserModel?.data?.user?.customStatus ?? "",
                      color: AppColor.whiteColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ]
                ],
              )

            ],
          ),
        );
      }
    );
  }

  openSettings(){
    pushScreen(screen: SettingScreen()).then((value) async{
      await Provider.of<CommonProvider>(context,listen: false).getUserByIDCall();
      await Provider.of<ChannelListProvider>(context,listen: false).refreshAllLists();
    });
  }

  Widget _buildExpansionSection({
    required String title,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColor.borderColor.withOpacity(0.05),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: List.generate(itemCount, (index) => itemBuilder(context, index)),
        ),
      ),
    );
  }


  Widget _buildAddButton() {
    return Container(
      height: 30,
      width: 30,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.lightBlueBgColor
      ),
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        icon: Icon(
          CupertinoIcons.plus,
          color: Colors.white,
          size: 20
        ),
        onPressed: () => showOptionsBottomSheet(context: context, options: options),
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
    // Determine item type based on index
    final itemType = index == 0 ? 'favoriteUser' : 'user';
    
    return Container(
     // color: muteConversation ? AppColor.borderColor.withOpacity(0.05) : null,
     margin: const EdgeInsets.symmetric(vertical: 6),
     child: InkWell(
       onTap: () => pushScreen(screen: SingleChatMessageScreen(userName: username, oppositeUserId: userId,calledForFavorite: true,)),
       onLongPress: () {
         // Get the appropriate provider data based on the type
         dynamic itemData;
         if (itemType == 'favoriteUser') {
           final favorites = Provider.of<ChannelListProvider>(context, listen: false)
               .favoriteListModel?.data?.chatList ?? [];
           
           for (var fav in favorites) {
             if (fav.sId == userId) {
               itemData = fav;
               break;
             }
           }
         } else {
           final directMessages = Provider.of<ChannelListProvider>(context, listen: false)
               .directMessageListModel?.data?.chatList ?? [];
               
           for (var dm in directMessages) {
             if (dm.sId == userId) {
               itemData = dm;
               break;
             }
           }
         }
         
         // Show the options dialog with the options from our helper method
         showOptionsDialog(
           context: context,
           title: username,
           options: _getOptionsForItem(
             itemType: itemType, 
             item: itemData,
             itemId: userId,
             itemName: username
           ),
         );
       },
       borderRadius: BorderRadius.circular(8),
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
         child: Row(
           children: [
             profileIconWithStatus(
               userName: username,
               userID: userId,
               otherUserProfile: imageUrl,
               status: status,
               isMuted: muteConversation,
             ),
             const SizedBox(width: 12),
             ConstrainedBox(
               constraints: BoxConstraints(minWidth: 0,maxWidth:MediaQuery.of(context).size.width * 0.5),
               child: commonText(
                 text: username,
                 color: muteConversation ? AppColor.borderColor : Colors.white.withOpacity(0.9),
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
               ),
             ),
             Visibility(
               visible: userId == signInModel.data?.user?.id,
               child: Padding(
                 padding: const EdgeInsets.only(left: 5.0),
                 child: commonText(text: "(you)",color: muteConversation ? AppColor.borderColor : Colors.white),
               )
             ),
             Visibility(
               visible: customStatusEmoji != "",
               child: Padding(
                 padding: const EdgeInsets.only(left: 8.0),
                 child: CachedNetworkImage(imageUrl: customStatusEmoji ?? "",height: 20,width: 20,),
               )
             ),
             // countMsgContainer(count : unSeenMsgCount ?? 0,isMuted: muteConversation),
             Spacer(),
             // Visibility(
             //   visible: muteConversation,
             //   child: Image.asset(AppImage.muteNotification,height: 20,width: 20,color: muteConversation ? AppColor.borderColor : Colors.white,)
             // ),
             ...?children,
           ],
         ),
       ),
     ),
    );
  }

  Widget _buildChannelRow(ChannelList channel) {
    print("channelID _buildChannelRow >>> ${channel.sId}");
    final muteChannel = signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false;
    return Container(
      // color: muteChannel ? AppColor.borderColor.withOpacity(0.05) : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          print("Channel Tapped");
          pushScreen(screen: ChannelChatScreen(channelId: channel.sId ?? "", /*channelName: channel.name!*/));
        },
        onLongPress: () {
          showOptionsDialog(
            context: context,
            title: channel.name ?? "Channel",
            options: _getOptionsForItem(
              itemType: 'channel',
              item: channel,
              itemId: channel.sId ?? "",
              itemName: channel.name ?? "Channel"
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Row(
            children: [
              commonChannelIcon(isPrivate: channel.isPrivate == true ? true : false,isMuted: muteChannel),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 0,maxWidth:MediaQuery.of(context).size.width * 0.5),
                child: commonText(
                  text: channel.name ?? "",
                  color: muteChannel ? AppColor.borderColor : Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // countMsgContainer(count : channel.unreadCount ?? 0,isMuted: muteChannel),
              Spacer(),
              dateAndColumnWidget(date: channel.lastmessage?.createdAt ?? "",unSeenMsgCount: channel.unreadCount ?? 0,mutedConversation: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false),
              // Visibility(
              //   visible: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false,
              //   child: Image.asset(AppImage.muteNotification,height: 20,width: 20,color: muteChannel ? AppColor.borderColor : Colors.white,)
              // ),
              // Comment out popup menu button
              // _buildPopupMenuForChannel(channelListModel: channel,),
            ],
          ),
        ),
      ),
    );
  }

  Visibility countMsgContainer({required int count, bool isMuted = false}) {
    return Visibility(
            visible: count != 0,
            child: Container(
              decoration: BoxDecoration(
                  color: isMuted ? Colors.white.withOpacity(0.8) : Colors.white,
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

  // Add new method for favorite channels
  Widget _buildFavoriteChannelRow(FavouriteChannels channel,List<Widget> children) {
    final isPrivate = channel.isPrivate;
    final name = channel.name;
    final unSeenCount = channel.unseenMessagesCount;
    final muteChannel = signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      // color: muteChannel ? AppColor.borderColor.withOpacity(0.05) : null,
      child: InkWell(
        onTap: ()=> pushScreen(screen: ChannelChatScreen(channelId: channel.sId ?? "", /*channelName: channel.name!*/)),
        onLongPress: () {
          showOptionsDialog(
            context: context,
            title: name ?? "Channel",
            options: _getOptionsForItem(
              itemType: 'favoriteChannel',
              item: channel,
              itemId: channel.sId ?? "",
              itemName: name ?? "Channel"
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Row(
            children: [
              commonChannelIcon(isPrivate: isPrivate ?? false,isMuted: muteChannel),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 0,maxWidth:MediaQuery.of(context).size.width * 0.5),
                child: commonText(
                  text: name ?? "",
                  color: muteChannel ? AppColor.borderColor : Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // countMsgContainer(count : unSeenCount ?? 0,isMuted: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false),

              Spacer(),
              // Visibility(
              //   visible: signInModel.data?.user?.muteChannels?.contains(channel.sId) ?? false,
              //   child: Image.asset(AppImage.muteNotification,height: 20,width: 20,color: muteChannel ? AppColor.borderColor : Colors.white,)
              // ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // Widget dateAndColumnWidget({required String? date,required int unSeenMsgCount,required bool mutedConversation}){
  //   print("dateAndColumnWidget>>>>> $date");
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       Text(formatDateTime2(date ?? ""),style: TextStyle(color:mutedConversation ? AppColor.borderColor : Colors.white),),
  //       mutedConversation ? Image.asset(AppImage.muteNotification,height: 20,width: 20,color: mutedConversation ? AppColor.borderColor : Colors.white,) :
  //       Visibility(
  //         visible: unSeenMsgCount > 0,
  //         child: Container(
  //           padding: EdgeInsets.all(5),
  //           decoration: BoxDecoration(color:AppColor.lightBlueColor,shape: BoxShape.circle),
  //           child: Center(child: commonText(text: unSeenMsgCount.toString(),color: Colors.white,fontSize: 15)),
  //         ),
  //       )
  //     ],
  //   );
  // }
  Widget dateAndColumnWidget({
    required String? date,
    required int unSeenMsgCount,
    required bool mutedConversation,
  }) {
    print("dateAndColumnWidget>>>>> $date");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatDateTime2(date ?? ""),
          style: TextStyle(
            color: mutedConversation ? AppColor.borderColor : Colors.white,
          ),
        ),
        // SizedBox(height: 5), // Adds spacing
        mutedConversation
            ? Image.asset(
          AppImage.muteNotification,
          height: 20,
          width: 20,
          color: AppColor.borderColor,
        )
            : Visibility(
          visible: unSeenMsgCount > 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.lightBlueColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: commonText(
                text: unSeenMsgCount.toString(),
                color: Colors.white,
                fontSize: 15, // Increased font size
                fontWeight: FontWeight.bold, // Makes it more readable
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Add these helper methods to separate items with and without unread messages
  Widget _buildItemsWithUnreadMessages(ChannelListProvider channelListProvider, CommonProvider commonProvider) {
    // Filter items with unread messages
    final itemsWithUnreadMessages = channelListProvider.combinedAllItems
        .where((item) => (item['unreadCount'] as int) > 0)
        .toList();
    
    if (itemsWithUnreadMessages.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemsWithUnreadMessages.length,
          itemBuilder: (context, index) {
            final item = itemsWithUnreadMessages[index];
            return _buildListItem(item, commonProvider);
          },
        ),
      ],
    );
  }
  
  Widget _buildItemsWithNoUnreadMessages(ChannelListProvider channelListProvider, CommonProvider commonProvider) {
    // Filter items with no unread messages
    final itemsWithNoUnreadMessages = channelListProvider.combinedAllItems
        .where((item) => (item['unreadCount'] as int) == 0)
        .toList();
    
    if (itemsWithNoUnreadMessages.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemsWithNoUnreadMessages.length,
          itemBuilder: (context, index) {
            final item = itemsWithNoUnreadMessages[index];
            return _buildListItem(item, commonProvider);
          },
        ),
      ],
    );
  }
  
  Widget _buildListItem(Map<String, dynamic> item, CommonProvider commonProvider) {
    final itemType = item['type'];
    final itemData = item['data'];
    
    switch (itemType) {
      case 'favoriteUser':
        final favorite = itemData as ChatList;
        return _buildUserRow(
          index: 0,
          muteConversation: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(favorite.sId ?? "") ?? false,
          imageUrl: favorite.thumbnailAvatarUrl ?? "",
          username: favorite.fullName ?? favorite.username ?? "",
          status: favorite.status ?? "",
          userId: favorite.sId ?? "",
          customStatusEmoji: favorite.customStatusEmoji ?? "",
          unSeenMsgCount: favorite.unseenMessagesCount,
          // Removed popup menu button
          children: [
            dateAndColumnWidget(date: favorite.latestMessageCreatedAt.toString(),unSeenMsgCount: favorite.unseenMessagesCount ?? 0,mutedConversation:commonProvider.getUserModel?.data?.user?.muteUsers?.contains(favorite.sId ?? "") ?? false )
          ]
        );
      
      case 'favoriteChannel':
        final favoriteChannel = itemData as FavouriteChannels;
        return _buildFavoriteChannelRow(
          favoriteChannel,
          // Removed popup menu button
          [
            dateAndColumnWidget(date: favoriteChannel.lastMessage.toString(),unSeenMsgCount: favoriteChannel.unseenMessagesCount ?? 0,mutedConversation:signInModel.data?.user?.muteChannels?.contains(favoriteChannel.sId) ?? false)
          ]
        );
      
      case 'channel':
        final channel = itemData as ChannelList;
        return _buildChannelRow(channel);
      
      case 'directMessage':
        final directMessage = itemData as ChatListDirectMessage;
        return _buildUserRow(
          muteConversation: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(directMessage.sId ?? "") ?? false,
          index: 2,
          imageUrl: directMessage.thumbnailAvatarUrl ?? "",
          username: directMessage.fullName ?? directMessage.username ?? "",
          status: directMessage.status ?? "",
          userId: directMessage.sId ?? "",
          customStatusEmoji: directMessage.customStatusEmoji ?? "",
          unSeenMsgCount: directMessage.unseenMessagesCount ?? 0,
          // Removed popup menu button
          children: [
            dateAndColumnWidget(date: directMessage.latestMessageCreatedAt.toString(),unSeenMsgCount: directMessage.unseenMessagesCount ?? 0,mutedConversation: commonProvider.getUserModel?.data?.user?.muteUsers?.contains(directMessage.sId ?? "") ?? false)
          ]
        );
      
      default:
        return SizedBox.shrink();
    }
  }

  // Add method to build the favorites tab
  Widget _buildFavoritesTab(ChannelListProvider channelListProvider, CommonProvider commonProvider) {
    // Filter only favorite items (favorite users and favorite channels)
    final favoriteItems = channelListProvider.combinedAllItems
        .where((item) => item['type'] == 'favoriteUser' || item['type'] == 'favoriteChannel')
        .toList();
    
    if (favoriteItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 60,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No Favorites",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Add favorites to see them here",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                    color: AppColor.white.withAlpha(15)
                ),
              );
            },
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
              return _buildListItem(item, commonProvider);
            },
          ),
        ),
      ),
    );
  }

  // Enhanced function to show options dialog with attractive UI
  void showOptionsDialog({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> options,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppPreferenceConstants.themeModeBoolValueGet 
                ? CupertinoColors.darkBackgroundGray 
                : AppColor.appBarColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.whiteColor)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: options.map((option) {
              return InkWell(
                onTap: () {
                  pop();
                  option['onTap']?.call();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColor.borderColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: option['color'] == Colors.red
                              ? Colors.red.withOpacity(0.1)
                              : AppColor.blueColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: option['icon'],
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: commonText(
                          text: option['title'] ?? '',
                          color: option['color'] ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
    );
  }

  // Generic function to get options for any item type
  List<Map<String, dynamic>> _getOptionsForItem({
    required String itemType,
    required dynamic item,
    required String itemId,
    required String itemName,
  }) {
    final channelListProvider = Provider.of<ChannelListProvider>(context, listen: false);
    final commonProvider = Provider.of<CommonProvider>(context, listen: false);
    
    // Common options structure
    final options = <Map<String, dynamic>>[];
    
    // Add mark as read/unread option
    if (itemType == 'user' || itemType == 'favoriteUser') {
      final unseenCount = item?.unseenMessagesCount ?? 0;
      options.add({
        'icon': Icon(Icons.mark_chat_unread_outlined, size: 20, color: Colors.white),
        'title': unseenCount > 0 ? "Mark as read" : "Mark as unread",
        'onTap': () {
          channelListProvider.readUnreadMessages(
            oppositeUserId: itemId,
            isCalledForFav: itemType == 'favoriteUser',
            isCallForReadMessage: unseenCount > 0
          );
        }
      });
    } else {
      // Channel options
      final unreadCount = itemType == 'channel' ? item?.unreadCount : item?.unseenMessagesCount;
      options.add({
        'icon': Icon(Icons.mark_chat_unread_outlined, size: 20, color: Colors.white),
        'title': (unreadCount ?? 0) > 0 ? "Mark as read" : "Mark as unread",
        'onTap': () {
          channelListProvider.readUnReadChannelMessage(
            oppositeUserId: itemId,
            isCallForReadMessage: (unreadCount ?? 0) > 0
          );
        }
      });
    }
    
    // Add favorite/unfavorite option
    if (itemType == 'favoriteUser') {
      options.add({
        'icon': Icon(Icons.star, size: 20, color: Colors.white),
        'title': "Unfavorite",
        'onTap': () => channelListProvider.removeFromFavorite(favouriteUserId: itemId)
      });
    } else if (itemType == 'user') {
      options.add({
        'icon': Icon(Icons.star_border, size: 20, color: Colors.white),
        'title': "Favorite", 
        'onTap': () => channelListProvider.addUserToFavorite(favouriteUserId: itemId)
      });
    } else if (itemType == 'favoriteChannel') {
      options.add({
        'icon': Icon(Icons.star, size: 20, color: Colors.white),
        'title': "Unfavorite",
        'onTap': () => channelListProvider.removeChannelFromFavorite(favoriteChannelID: itemId)
      });
    } else if (itemType == 'channel') {
      options.add({
        'icon': Icon(Icons.star_border, size: 20, color: Colors.white),
        'title': "Favorite",
        'onTap': () => channelListProvider.addChannelToFavorite(channelId: itemId)
      });
    }
    
    // Add mute/unmute option
    if (itemType == 'user' || itemType == 'favoriteUser') {
      final isMuted = commonProvider.getUserModel?.data?.user?.muteUsers?.contains(itemId) ?? false;
      options.add({
        'icon': Icon(
          isMuted ? Icons.notifications_none : Icons.notifications_off_outlined,
          size: 20,
          color: Colors.white
        ),
        'title': isMuted ? "Unmute Conversation" : "Mute Conversation",
        'onTap': () => channelListProvider.muteUser(
          userIdToMute: itemId,
          isForMute: isMuted
        )
      });
    } else {
      final isMuted = signInModel.data?.user?.muteChannels?.contains(itemId) ?? false;
      options.add({
        'icon': Icon(
          isMuted ? Icons.notifications_none : Icons.notifications_off_outlined,
          size: 20,
          color: Colors.white
        ),
        'title': isMuted ? "Unmute Channel" : "Mute Channel",
        'onTap': () => channelListProvider.muteUnMuteChannels(
          channelId: itemId,
          isMutedChannel: isMuted
        )
      });
    }
    
    // Add leave/close option
    if (itemType == 'user' || itemType == 'favoriteUser') {
      options.add({
        'icon': Icon(Icons.exit_to_app, size: 20, color: Colors.red),
        'title': "Close Conversation",
        'color': Colors.red,
        'onTap': () => channelListProvider.closeConversation(
          conversationUserId: itemId,
          isCalledForFav: itemType == 'favoriteUser'
        )
      });
    } else {
      options.add({
        'icon': Icon(Icons.exit_to_app, size: 20, color: Colors.red),
        'title': "Leave Channel",
        'color': Colors.red,
        'onTap': () => leaveChannelDialog(itemId)
      });
    }
    
    return options;
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




