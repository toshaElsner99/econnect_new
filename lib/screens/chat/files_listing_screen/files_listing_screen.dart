import 'package:e_connect/cubit/chat/chat_cubit.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/download_provider.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';
import '../../../utils/common/common_function.dart';
import '../../../utils/common/common_widgets.dart';

class FilesListingScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  const FilesListingScreen({super.key, required this.userName,required this.oppositeUserId});

  @override
  State<FilesListingScreen> createState() => _FilesListingScreenState();
}

class _FilesListingScreenState extends State<FilesListingScreen> {
  @override
  void initState() {
    Provider.of<ChatProvider>(context,listen: false).getFileListingInChat(oppositeUserId: widget.oppositeUserId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Divider(color: Colors.grey.shade800, height: 1),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            commonText(text: "Files", fontSize: 16),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: commonText(
                text: " | ${widget.userName}",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColor.borderColor,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final messages = chatProvider.filesListingInChatModel?.data?.messages;

          return messages?.length == 0 ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImage.fileIcon,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,height: 100,width: 100,),
                SizedBox(height: 10),
                commonText(text: "No file posts yet",fontSize: 18),
              ],
            ),
          ) : Column(
            children: [
              Visibility(
                visible: messages != null && messages.isNotEmpty,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: commonText(
                      text: "Recent files",
                      color: AppColor.borderColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: messages?.length ?? 0,
                  itemBuilder: (context, index) {
                    final message = messages![index];
                    final files = message.files;

                    return Column(
                      children: files?.map((fileUrl) {
                        String originalFileName = getFileName(fileUrl);
                        String formattedFileName = formatFileName(originalFileName);
                        String fileType = getFileExtension(originalFileName);

                        return Container(
                          margin: EdgeInsets.only(top: 7, right: 15,left: 15),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.lightGreyColor),
                          ),
                          child: Row(
                            children: [
                              getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$fileUrl"),
                              SizedBox(width: 20),
                              commonText(text: formattedFileName, maxLines: 1,overflow: TextOverflow.ellipsis),
                              Spacer(),
                              GestureDetector(
                                onTap: () => Provider.of<DownloadFileProvider>(context, listen: false).downloadFile(
                                  fileUrl: "${ApiString.profileBaseUrl}$fileUrl",
                                  context: context,
                                ),
                                child: Image.asset(
                                  AppImage.downloadIcon,
                                  fit: BoxFit.contain,
                                  height: 20,
                                  width: 20,
                                  color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList() ?? [],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}