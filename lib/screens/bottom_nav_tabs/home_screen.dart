import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/screens/browse_and_search_channel/browse_and_search_channel.dart';
import 'package:e_connect/screens/create_channel_screen/create_channel_screen.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../utils/common/common_function.dart';
import '../chat/single_chat_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
      onTap: () => null,
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
    channelListCubit.getFavoriteList();
    channelListCubit.getChannelList();
    channelListCubit.getDirectMessageList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.commonAppColor,
      body: BlocBuilder<ChannelListCubit, ChannelListState>(
        bloc: channelListCubit,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildExpansionSection(
                    title: "FAVORITES",
                    index: 0,
                    itemCount: channelListCubit
                            .favoriteListModel?.data?.chatList?.length ??
                        0,
                    itemBuilder: (context, index) {
                      final favorite = channelListCubit
                          .favoriteListModel?.data?.chatList?[index];
                      return _buildUserRow(
                        imageUrl: favorite?.avatarUrl ?? "",
                        username: favorite?.username ?? "",
                        status: favorite?.status ?? "",
                        userId: favorite?.sId ?? "",
                        customStatusEmoji: favorite?.customStatusEmoji ?? "",
                        unSeenMsgCount: favorite?.unseenMessagesCount ?? 0,
                      );
                    },
                  ),
                  _buildExpansionSection(
                    title: "CHANNEL",
                    index: 1,
                    trailing: _buildAddButton(),
                    itemCount:
                        channelListCubit.channelListModel?.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final channel =
                          channelListCubit.channelListModel!.data![index];
                      return _buildChannelRow(channel);
                    },
                  ),
                  _buildExpansionSection(
                    index: 2,
                    title: "DIRECT MESSAGE",
                    itemCount: channelListCubit
                            .directMessageListModel?.data?.chatList?.length ??
                        0,
                    trailing: _buildAddButton(),
                    itemBuilder: (context, index) {
                      final directMessage = channelListCubit
                          .directMessageListModel!.data!.chatList?[index];
                      return _buildUserRow(
                          imageUrl: directMessage?.avatarUrl ?? "",
                          username: directMessage?.username ?? "",
                          status: directMessage?.status ?? "",
                          userId: directMessage?.sId ?? "",
                          customStatusEmoji:
                              directMessage?.customStatusEmoji ?? "",
                          unSeenMsgCount:
                              directMessage?.unseenMessagesCount ?? 0);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
      child: TextFormField(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: 'Find Channels...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Colors.white.withOpacity(0.5),
            size: 18,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.search,
      ),
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
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: (_isExpanded[title] ?? false)
                          ? MediaQuery.of(context).size.height * 0.4
                          : 0,
                    ),
                    child: ListView.builder(
                      itemCount: itemCount,
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: itemBuilder,
                    ),
                  ),
                ),
              ],
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
    required String imageUrl,
    required String username,
    required String status,
    required String userId,
    String? customStatusEmoji = "",
    int? unSeenMsgCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          // Handle user row tap
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleChatMessageScreen(
                      userName: username,
                      oppositeUserId: userId,
                    )),
          );
        },
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
                    child: commonText(text: "(you)", color: Colors.white),
                  )),
              Visibility(
                  visible: customStatusEmoji != "",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: customStatusEmoji!,
                      height: 20,
                      width: 20,
                    ),
                  )),
              Visibility(
                  visible: unSeenMsgCount != 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                    margin: EdgeInsets.only(left: 5),
                    child: commonText(text: "$unSeenMsgCount"),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelRow(channel) {
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
              Image.asset(
                channel?.isPrivate == true
                    ? AppImage.lockIcon
                    : AppImage.globalIcon,
                width: 16,
                height: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: commonText(
                  text: channel?.name ?? "",
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
