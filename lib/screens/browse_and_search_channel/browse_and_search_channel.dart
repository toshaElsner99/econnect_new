import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/common/common_widgets.dart';

class BrowseAndSearchChannel extends StatefulWidget {
  const BrowseAndSearchChannel({super.key});

  @override
  State<BrowseAndSearchChannel> createState() => _BrowseAndSearchChannelState();
}

class _BrowseAndSearchChannelState extends State<BrowseAndSearchChannel> {

  final _searchController = TextEditingController();
  final channelListCubit = ChannelListCubit();

  @override
  void initState() {
    super.initState();
    channelListCubit.browseAndSearchChannel(search: _searchController.text);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.commonAppColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:  commonText(
          text: 'New Channel',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
        ),
      ),
      body: BlocConsumer(
        bloc: channelListCubit,
        builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text('${filteredChannels.length} Results',
                  //     style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      Text('Hide Joined')
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: channelListCubit.browseAndSearchChannelModel?.data?.channels?.length ?? 0,
                itemBuilder: (context, index) {
                  final channelListing = channelListCubit.browseAndSearchChannelModel?.data?.channels?[index];
                  return Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(channelListing!.isPrivate == true ? AppImage.lockIcon : AppImage.persons,width: 16, height: 16, color: Colors.black,),
                        Flexible(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          commonText(text: "${channelListing.name}"),
                          Row(children: [
                            Icon(CupertinoIcons.person),
                            commonText(text: ""),
                          ],)
                        ],))
                      ],
                    ),

                  );
                },
              ),
            ),
          ],
        );
      }, listener: (context, state) {},),
    );
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

