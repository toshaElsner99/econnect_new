import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/screens/chat/single_chat_message_screen.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/channel_list_provider.dart';
import '../../utils/app_color_constants.dart';
import '../../utils/app_image_assets.dart';
import '../../utils/common/common_widgets.dart';

class FindChannelScreen extends StatefulWidget {
  const FindChannelScreen({super.key});

  @override
  State<FindChannelScreen> createState() => _FindChannelScreenState();
}

class _FindChannelScreenState extends State<FindChannelScreen> {
  final _searchController = TextEditingController();
  // final channelListCubit = ChannelListCubit();
  @override
  void initState() {
    super.initState();
    context.read<ChannelListProvider>().browseAndSearchChannel(search: _searchController.text);

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty && _searchController.text.length > 3) {
        context.read<ChannelListProvider>().browseAndSearchChannel(search: _searchController.text);
      }  else if(_searchController.text.isEmpty){
        context.read<ChannelListProvider>().browseAndSearchChannel(search: "");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.close,color: Colors.white,),
            onPressed: () => Navigator.pop(context),
          ),
          title: commonText(
            text: 'Find Channel',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        body: Consumer<ChannelListProvider>(builder: (context, channelListProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: commonTextFormField(
                  controller: _searchController,
                  hintText: 'Search users or channels',
                  prefixIcon: const Icon(CupertinoIcons.search),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Users Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Image.asset(AppImage.persons,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,),
                            SizedBox(width: 5,),
                            commonText(
                              text: 'Users',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      if (channelListProvider.browseAndSearchChannelModel?.data?.users?.isEmpty ?? true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Center(
                            child: commonText(
                              text: 'No users found',
                              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: channelListProvider.browseAndSearchChannelModel?.data?.users?.length ?? 0,
                          itemBuilder: (context, index) {
                            final user = channelListProvider.browseAndSearchChannelModel?.data?.users?[index];
                            return _buildUserTile(user);
                          },
                        ),

                      const SizedBox(height: 16),

                      // Channels Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Image.asset(AppImage.globalIcon,width: 20,height: 20,),
                            SizedBox(width: 5,),
                            commonText(
                              text: 'Channels',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      if (channelListProvider.browseAndSearchChannelModel?.data?.channels?.isEmpty ?? true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Center(
                            child: commonText(
                              text: 'No channels found',
                              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: channelListProvider.browseAndSearchChannelModel?.data?.channels?.length ?? 0,
                          itemBuilder: (context, index) {
                            final channel = channelListProvider.browseAndSearchChannelModel?.data?.channels?[index];
                            return _buildChannelTile(channel);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },),
      ),
    );
  }

  Widget _buildUserTile(dynamic user) {
    return ListTile(
      onTap: () => pushReplacement(screen: SingleChatMessageScreen(userName: user?.username ?? "", oppositeUserId: user?.userId ?? "",needToCallAddMessage: true,)),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          ApiString.profileBaseUrl + (user?.avatarUrl ?? ""),
        ),
      ),
      title: commonText(
        text: user?.username ?? "",
        // color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildChannelTile(dynamic channel) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColor.borderColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Image.asset(
            channel?.isPrivate == true ? AppImage.lockIcon : AppImage.globalIcon,
            width: 20,
            height: 20,
            color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
      title: commonText(
        text: channel?.name ?? "",
        // color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      subtitle: Row(
        children: [
          SizedBox(height: 10,),
          Image.asset(
            AppImage.person,
            height: 12,
            width: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          commonText(
            text: "${channel?.members?.length ?? 0}",
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }
}
