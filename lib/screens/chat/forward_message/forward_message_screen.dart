import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/channel_list_provider.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_preference_constants.dart';
import '../../../utils/common/common_function.dart';
import '../../../utils/common/common_widgets.dart';

class ForwardMessageScreen extends StatefulWidget {
  final String msgToForward;
  final String userID;
  final String otherUserProfile;
  final String userName;
  final String time;

  const ForwardMessageScreen({
    super.key,
    required this.time,
    required this.userName,
    required this.userID,
    required this.msgToForward,
    required this.otherUserProfile,
  });

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChannelListProvider>().browseAndSearchChannel(search: searchController.text,needLoader: true,combineList: true);
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        context.read<ChannelListProvider>().browseAndSearchChannel(search: searchController.text,combineList: true);
      }else {
        context.read<ChannelListProvider>().browseAndSearchChannel(search: "",combineList: true);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(onPressed: () => pop(), icon: Icon(Icons.close)),
        titleSpacing: 0,
        title: commonText(text: "Forward Message", color: Colors.white)
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1,),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColor.appBarColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.borderColor.withOpacity(0.5))),
            margin: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.white,),
                SizedBox(width: 10,),
                Flexible(child: commonText(text: "This message is from a private conversation", fontSize: 18,fontWeight: FontWeight.w500,height: 1.2)),
              ],
            ),
          ),
          SearchBar(

          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
            child: commonTextFormField(
                controller: TextEditingController(),
                hintText: "Add a comment (optional)"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: commonText(
              text: "Message preview",
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: AppColor.boxBgColor,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppColor.borderColor)),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    profileIconWithStatus(
                        userID: widget.userID,
                        status: "",
                        otherUserProfile: widget.otherUserProfile,
                        needToShowIcon: false,
                        radius: 16),
                    SizedBox(width: 5),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        commonText(text: widget.userName),
                        SizedBox(height: 4),
                        commonText(text: widget.time,color: AppColor.borderColor,fontWeight: FontWeight.w400,fontSize: 12),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                  child: commonHTMLText(message: widget.msgToForward),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 20),
            child: Row(
              children: [
                Flexible(child: Container(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.borderColor)
                  ),
                    child: commonElevatedButton(onPressed: () => pop(), buttonText: "Cancel",backgroundColor: Colors.transparent,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))),
                Flexible(child: commonElevatedButton(onPressed: () {}, buttonText: "Forward"))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class CombinedItem {
  final bool isChannel;
  final dynamic item; // Can be User or Channel

  CombinedItem({required this.isChannel, required this.item});
}
