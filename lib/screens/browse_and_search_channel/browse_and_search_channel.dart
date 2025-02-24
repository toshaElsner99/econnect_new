import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/channel_list_provider.dart';
import '../../utils/common/common_widgets.dart';

class BrowseAndSearchChannel extends StatefulWidget {
  const BrowseAndSearchChannel({super.key});

  @override
  State<BrowseAndSearchChannel> createState() => _BrowseAndSearchChannelState();
}

class _BrowseAndSearchChannelState extends State<BrowseAndSearchChannel> {
  final _searchController = TextEditingController();
  bool hideJoined = false;

  @override
  void initState() {
    super.initState();
    context.read<ChannelListProvider>().browseAndSearchChannel(search: _searchController.text,needLoader: true);

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        context.read<ChannelListProvider>().browseAndSearchChannel(search: _searchController.text);
      }else {
        context.read<ChannelListProvider>().browseAndSearchChannel(search: "");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: commonText(
          text: 'Browse Channel',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Consumer<ChannelListProvider>(builder: (context, channelListProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: commonTextFormField(
                controller: _searchController,
                hintText: 'Search Channel',
                prefixIcon: const Icon(CupertinoIcons.search),

              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${channelListProvider.browseAndSearchChannelModel?.data?.channels?.length ?? 0} Results',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Checkbox(
                          value: hideJoined,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (bool? value) {
                            setState(() {
                              hideJoined = value ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          activeColor: AppColor.commonAppColor,
                        ),
                      ),
                      commonText(text: 'Hide Joined'),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: AppColor.borderColor),

            // Expanded(
            //   child: ListView.builder(
            //     itemCount: channelListProvider.browseAndSearchChannelModel?.data?.channels
            //         ?.where((channel) => !hideJoined || !(channel.members?.any((member) => member.id == signInModel.data?.user?.id) ?? false))
            //         .length ?? 0,
            //     itemBuilder: (context, index) {
            //       final filteredChannels = channelListProvider.browseAndSearchChannelModel?.data?.channels
            //           ?.where((channel) => !hideJoined || !(channel.members?.any((member) => member.id == signInModel.data?.user?.id) ?? false))
            //           .toList();
            //
            //       final channelListing = filteredChannels?[index];
            //
            //       return Container(
            //         decoration: BoxDecoration(
            //           border: Border(bottom: BorderSide(color: AppColor.borderColor)),
            //         ),
            //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //         child: Row(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             commonChannelIcon(
            //               isPrivate: channelListing!.isPrivate == true ? true : false,
            //               isShowPersons: true,
            //               color: AppColor.commonAppColor,
            //             ),
            //             const SizedBox(width: 10),
            //             Expanded(
            //               child: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   commonText(text: "${channelListing.name}", height: 1.2),
            //                   const SizedBox(height: 10),
            //                   Row(
            //                     children: [
            //                       Image.asset(AppImage.person, height: 16, width: 16, color: AppColor.borderColor),
            //                       commonText(
            //                         text: channelListing.members!.length.toString(),
            //                         color: AppColor.borderColor,
            //                       ),
            //                     ],
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             Container(
            //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(5),
            //                 border: Border.all(width: 1, color: AppColor.commonAppColor),
            //               ),
            //               child: commonText(text: "View", color: AppColor.commonAppColor),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // )
            Expanded(
              child: Builder(
                builder: (context) {
                  final filteredChannels = channelListProvider.browseAndSearchChannelModel?.data?.channels
                      ?.where((channel) => !hideJoined || !(channel.members?.any((member) => member.id == signInModel.data?.user?.id) ?? false))
                      .toList();

                  if (filteredChannels == null || filteredChannels.isEmpty) {
                    return Center(
                      child: commonText(
                        text: "No Channel Found",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredChannels.length,
                    itemBuilder: (context, index) {
                      final channelListing = filteredChannels[index];

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColor.borderColor)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonChannelIcon(
                              isPrivate: channelListing.isPrivate == true ? true : false,
                              isShowPersons: true,
                              color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.appBarColor,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  commonText(text: "${channelListing.name}", height: 1.2),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Image.asset(AppImage.person, height: 16, width: 16, color: AppColor.borderColor),
                                      commonText(
                                        text: channelListing.members!.length.toString(),
                                        color: AppColor.borderColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(width: 1, color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.commonAppColor),
                              ),
                              child: commonText(text: "View", color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.commonAppColor),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )


          ],
        );
      },),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }
}
