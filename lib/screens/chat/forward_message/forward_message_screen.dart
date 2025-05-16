import 'dart:developer';

import 'package:e_connect/main.dart';
import 'package:e_connect/providers/chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  final String forwardMsgId;
  final bool? isForBdy;

  const ForwardMessageScreen({
    super.key,
    required this.time,
    required this.userName,
    required this.userID,
    required this.msgToForward,
    required this.otherUserProfile,
    required this.forwardMsgId, this.isForBdy,
  });

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {

  final provider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
  final contentController = TextEditingController();
  final FocusNode searchPeopleNode = FocusNode();
  final FocusNode addCommentNode = FocusNode();
  List itemInfo = [];
  @override
  void initState() {
    super.initState();
    itemInfo.clear();
    log("UserId : ${widget.userID}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.clearList();
      provider.searchController.addListener(() {
        if (provider.searchController.text.isNotEmpty && provider.searchController.text.length >= 2) {
          context.read<ChannelListProvider>().browseAndSearchChannel(search: provider.searchController.text,combineList: true);
        }else {
          context.read<ChannelListProvider>().browseAndSearchChannel(search: "",combineList: true);
          if(provider.searchController.text.isEmpty){
            provider.clearList();
          }
        }
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(onPressed: () => Cf.instance.pop(), icon: Icon(Icons.close,color: Colors.white,)),
        titleSpacing: 0,
        title: Cw.instance.commonText(text: "Forward Message", color: Colors.white)
      ),
      body: Consumer2<ChannelListProvider,ChatProvider>(builder: (context, channelListProvider,chatProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 1),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppPreferenceConstants.themeModeBoolValueGet == false ? AppColor.appBarColor : AppColor.appBarColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.borderColor.withOpacity(0.5))),
                margin: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: Colors.white,),
                    SizedBox(width: 10,),
                    Flexible(child: Cw.instance.commonText(text: "This message is from a private conversation", fontSize: 18,fontWeight: FontWeight.w500,height: 1.2,color: Colors.white)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  children: itemInfo.map((item) => Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Chip(
                      label: Cw.instance.commonText(text: item['name'] ?? "unknow",fontSize: 12),
                      onDeleted: () {
                        setState(() {
                          itemInfo.remove(item);
                        });
                      },
                    ),
                  )).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 20,left: 20),
                child: Container(child: Cw.instance.commonTextFormField(
                    focusNode: searchPeopleNode,
                    controller: channelListProvider.searchController, hintText: "Search People",suffixIcon: channelListProvider.combinedList.isEmpty ? null : IconButton(onPressed: () => channelListProvider.clearList(), icon: Icon(Icons.close)))),
              ),
              Visibility(
                visible: (channelListProvider.searchController.text.isNotEmpty && channelListProvider.combinedList.isNotEmpty),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:  MediaQuery.of(context).size.height * 0.3,
                    minHeight: 10
                  ),
                  child: Stack(
                    children: [
                    if(channelListProvider.isLoading == true)...{
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            color: Colors.black.withOpacity(0.2)
                        ),
                        child: const SpinKitCircle(
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    },
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white12 : Colors.white,
                          border: Border.all(color: AppColor.borderColor),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: channelListProvider.combinedList.length,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          itemBuilder: (context, index) {
                            final list = channelListProvider.combinedList[index];
                            String displayName = "";
                            
                            if (list['type'] == "user") {
                              // Remove underscores from username for display
                              displayName = (list['username'] ?? list['fullName'] ?? "Unknown User").toString().replaceAll("_", " ");
                            } else {
                              displayName = (list['name'] ?? "Unnamed Channel").toString();
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (list['type'] == "user") {
                                    itemInfo.add({
                                      'type': "user",
                                      'name': list['fullName'] ?? displayName,
                                      'id': list['userId'],
                                    });
                                  } else {
                                    itemInfo.add({
                                      'type': "channel",
                                      'name': displayName,
                                      'id': list['id'],
                                    });
                                  }
                                  channelListProvider.clearList();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Row(
                                  children: [
                                    if (list['type'] == 'user') ...{
                                      Cw.instance.profileIconWithStatus(
                                        userName: displayName,
                                        userID: list['userId'],
                                        status: "",
                                        needToShowIcon: false,
                                        otherUserProfile: list['avatarUrl'],
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(child: Cw.instance.commonText(text: displayName))
                                    } else ...{
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(13),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Cw.instance.commonText(
                                          text: displayName.isNotEmpty ? displayName[0].toString().toUpperCase() : "#",
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(child: Cw.instance.commonText(text: displayName, maxLines: 1))
                                    },
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                        ),
                      ) ,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
                child: Cw.instance.commonTextFormField(
                    focusNode: addCommentNode,
                    controller: contentController,
                    hintText: "Add a comment (optional)"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Cw.instance.commonText(
                  text: "Message preview",
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.boxBgColor : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColor.borderColor)),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Cw.instance.profileIconWithStatus(
                          userName: widget.userName,
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
                            Cw.instance.commonText(text: widget.userName),
                            SizedBox(height: 4),
                            Cw.instance.commonText(text: widget.time,color: AppColor.borderColor,fontWeight: FontWeight.w400,fontSize: 12),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                      child: widget.isForBdy?? false ? Cw.instance.HtmlTextOnly(htmltext: widget.msgToForward)  : Cw.instance.commonHTMLText(message: widget.msgToForward),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                child: Row(
                  children: [
                    Flexible(child: Container(
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.borderColor)
                        ),
                        child: Cw.instance.commonElevatedButton(onPressed: () => Cf.instance.pop(), buttonText: "Cancel",backgroundColor: Colors.transparent,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))),
                    Flexible(child: Cw.instance.commonElevatedButton(onPressed: () {
                      Cf.instance.pop();
                      for (var item in itemInfo) {
                        if (item['type'] == 'user') {
                          chatProvider.forwardMessage(forwardBody: {
                            "content": contentController.text.trim(),
                            "receiverId": item['id'],
                            "senderId": signInModel!.data?.user!.id,
                            "isForwarded": true.toString(),
                            "forwardFrom": widget.forwardMsgId
                          }, );
                        } else if (item['type'] == 'channel') {
                          chatProvider.forwardMessage(forwardBody: {
                            "content": contentController.text.trim(),
                            "isForwarded": true.toString(),
                            "forwardFrom": widget.forwardMsgId,
                            "channelId": item['id']
                          }, );
                        }
                      }

                    }, buttonText: "Forward"))
                  ],
                ),
              ),
            ],
          ),
        );
      },),
    );
  }
}
class CombinedItem {
  final bool isChannel;
  final dynamic item;

  CombinedItem({required this.isChannel, required this.item});
}
