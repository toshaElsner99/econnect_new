import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/searchMessages.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/common_provider.dart';
import '../../providers/search_message_provider.dart';
import '../../utils/app_image_assets.dart';
import '../../utils/app_preference_constants.dart';

class FindMessageScreen extends StatefulWidget {
  const FindMessageScreen({super.key});

  @override
  State<FindMessageScreen> createState() => _FindMessageScreenState();
}

class _FindMessageScreenState extends State<FindMessageScreen> {
  final _searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();


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
            onPressed: () => Navigator.pop(context,),
          ),
          title: commonText(
            text: 'Find Messages',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: commonTextFormField(
                controller: _searchController,
                hintText: 'Search Messages',
                prefixIcon: const Icon(CupertinoIcons.search),
                fieldSubmitted: (value) {
                  context.read<SearchMessageProvider>().browseAndSearchMessages(search: value!);
                },
              ),
            ),
            Expanded(
              child: Consumer<SearchMessageProvider>(
                builder: (context,value,a){
                  print("value.messageGroups.length");
                  print(value.messageGroups.length);
                  if(value.messageGroups.length == 0){
                    return Center(child: commonText(text: "No data found"),);
                  }
                  return ListView.builder(
                    itemCount: value.messageGroups.length,
                    itemBuilder: (context, index) {
                      final messageData = value.messageGroups[index];
                      final dateFormatted =formatDateTime(DateTime.parse(messageData.date.toString()));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0,top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Expanded(child: Divider()), // Left side line
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: commonText(
                                      text: dateFormatted,
                                        fontSize: 13,color: Colors.grey
                                    ),
                                  ),
                                  Expanded(child: Divider()), // Right side line
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: messageData.messages.length,
                              itemBuilder: (context, msgIndex) {
                                final message = messageData.messages[msgIndex];
                                final sender = message.senderInfo?.username;
                                final channel = message.channelInfo?.name ?? '';
                                final content = message.content;
                                final isForwarded = message.isForwarded;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: InkWell(
                                    onTap: ()async{
                                      // print("Is From Channel ${message.channelInfo != null ? true : false}");
                                      await value.getPageNumber(messageId: message.id, senderId: message.senderId,receiverId: message.receiverId!).then((int pageNumber) {
                                        print("Page number $pageNumber");
                                        Navigator.pop(context,{"id":message.senderInfo?.id,"oppositeUserID":message.oppositeUserInfo?.id,"oppositeUserName":message.oppositeUserInfo!.username,"name":message.senderInfo!.username,"needToOpenChannelChat":message.channelInfo != null ? true : false,"channelId":message.channelInfo != null ? message.channelInfo?.id : "","pageNO":pageNumber});
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8,),
                                        commonText(text : channel != "" ? channel :"Direct Message (With ${message.oppositeUserInfo?.username})",fontSize: 18,color: Colors.grey),
                                        SizedBox(height: 10,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.grey[200],
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: signInModel.data?.user?.id == message.senderInfo?.id
                                                          ? ApiString.profileBaseUrl + (signInModel.data!.user!.thumbnailAvatarUrl ?? '')
                                                          : ApiString.profileBaseUrl + (message.senderInfo?.thumbnailAvatarUrl ?? ''),
                                                      width: 25 * 2,
                                                      height: 25 * 2,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                      errorWidget: (context, url, error) => Icon(Icons.error, size: 25),
                                                    ),
                                                  ),
                                                ),
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                          color:message.senderInfo == null ? Colors.white : message.senderInfo!.status.name.contains("offline") ? Colors.transparent : Colors.white,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      getCommonStatusIcons(status: message.senderInfo!.status.name, size: 20, assetIcon: false),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            // profileIconWithStatus(
                                            //   userID: message.senderInfo.id,
                                            //   status: "",
                                            //   needToShowIcon: false,
                                            //   radius: 12,
                                            //   otherUserProfile: message.senderInfo.thumbnailAvatarUrl,
                                            //   containerSize: 20
                                            // ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  commonText(text : sender!,fontSize: 18),
                                                  SizedBox(height: 10),
                                                  commonHTMLText(message: content),
                                                ],
                                              ),
                                            ),
                                            // if (isForwarded) Icon(Icons.forward),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                                // return ListTile(
                                //   leading: CircleAvatar(
                                //     backgroundImage: NetworkImage(message.senderInfo.thumbnailAvatarUrl),
                                //   ),
                                //   title: Text(sender),
                                //   subtitle: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       channel != "" ? Text('Channel: $channel') : Text("Direct Message ( With ${message.oppositeUserInfo.username})"),
                                //       SizedBox(height: 4),
                                //       Text(content),
                                //     ],
                                //   ),
                                //   trailing: isForwarded ? Icon(Icons.forward) : null,
                                // );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

            ),
          ],
        ),
      ),
    );
  }


}
