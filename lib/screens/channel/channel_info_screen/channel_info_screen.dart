import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/channel_list_provider.dart';
import '../../../main.dart';
import '../../../utils/common/common_function.dart';
import '../channel_member_info_screen/channel_members_info.dart';
import '../channel_pinned_messages/channel_pinned_messages_screen.dart';
import '../files_listing_channel/files_listing_in_channel_screen.dart';
// import 'channel_members_info.dart';

class ChannelInfoScreen extends StatelessWidget {
  final String channelId;
  final String channelName;
  final bool isPrivate;
  final String description;

  const ChannelInfoScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    required this.isPrivate,
    this.description = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        // backgroundColor: Colors.black,
        leading: commonBackButton(),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(text: "Info", fontSize: 16),
            const SizedBox(height: 4),
            commonText(text: channelName,maxLines: 1,fontSize: 12,color: AppColor.borderColor),
          ],
        ),
      ),
      body: Column(
        children: [
          // Favorite and Mute buttons
          Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon:
                      channelChatProvider.getChannelInfo?.data?.isFavourite == true
                          ? Icons.star
                          :
                      Icons.star_border,
                      label:  channelChatProvider.getChannelInfo?.data?.isFavourite == true ? 'Favorited':'Favorite',
                      onTap: () {
                        context.read<ChannelListProvider>().addChannelToFavorite(
                          channelId: channelId,
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.notifications_off_outlined,
                      label: signInModel.data?.user?.muteChannels?.contains(channelId) ?? false ? 'Muted' : 'Mute',
                      onTap: () {
                        context.read<ChannelListProvider>().muteUnMuteChannels(
                          channelId: channelId,
                          isMutedChannel: signInModel.data?.user?.muteChannels?.contains(channelId) ?? false,
                        );
                      },
                    ),
                  ],
                ),
              );
            }
          ),

          // Channel Avatar and Name
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 30,
                  child: Text(
                    channelName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  channelName,
                  style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: $channelId',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Members, Pinned Messages, Files sections
          Consumer<ChannelChatProvider>(
            builder: (context, provider, child) {
              // Get the members count when screen loads
              if (provider.channelMembersList.isEmpty) {
                provider.getChannelMembersList(channelId);
              }

              return _buildInfoSection(
                icon: Icons.people_outline,
                title: 'Members',
                count: provider.channelMembersList.length.toString(),
                onTap: () => pushScreen(screen: ChannelMembersInfo(channelId: channelId, channelName: channelName)),
              );
            },
          ),
          Consumer<ChannelChatProvider>(
              builder: (context, provider, child) {
              return _buildInfoSection(
                icon: Icons.push_pin_outlined,
                title: 'Pinned Messages',
                count: provider.getChannelInfo?.data?.pinnedMessagesCount != null ?
                provider.getChannelInfo?.data?.pinnedMessagesCount.toString() :
                '0',
                onTap: () => pushScreen(screen: ChannelPinnedPostsScreen(channelName: channelName, channelId: channelId)),
              );
            }
          ),
        Consumer<ChannelChatProvider>(builder: (context, value, child) {
          return  _buildInfoSection(
            icon: Icons.folder_outlined,
            title: 'Files',
            count: value.filesListingInChannelChatModel?.data?.messages?.length.toString() ?? "0",
            onTap: () => pushScreen(screen: FilesListingScreen(channelName: channelName, channelId: channelId)),
          );
        },),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              // color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                // color: Colors.white,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              count!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
} 