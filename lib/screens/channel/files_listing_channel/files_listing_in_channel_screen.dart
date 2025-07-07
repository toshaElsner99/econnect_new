import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../../../providers/download_provider.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';
import '../../../utils/common/common_function.dart';
import '../../../utils/common/common_widgets.dart';
import '../../../widgets/audio_widget.dart';

class FilesListingScreen extends StatefulWidget {
  final String channelName;
  final String channelId;
  const FilesListingScreen({super.key, required this.channelName,required this.channelId});

  @override
  State<FilesListingScreen> createState() => _FilesListingScreenState();
}

class _FilesListingScreenState extends State<FilesListingScreen> {
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, Duration> _audioDurations = {};
  AudioPlayer? _currentlyPlayingPlayer;
  void _handleAudioPlayback(String audioUrl, AudioPlayer player) {
    // If there's already an audio playing and it's different from the new one
    if (_currentlyPlayingPlayer != null && _currentlyPlayingPlayer != player) {
      _currentlyPlayingPlayer!.stop();
    }
    setState(() => _currentlyPlayingPlayer = player);
  }
  @override
  void initState() {
    Provider.of<ChannelChatProvider>(context,listen: false).getFileListingInChannelChat(channelId: widget.channelId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Cw.commonBackButton(),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Divider(color: Colors.grey.shade800, height: 1),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Cw.commonText(text: "Files", fontSize: 16),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Cw.commonText(
                text: " | ${widget.channelName}",
                fontSize: 12,
                maxLines: 1,
                fontWeight: FontWeight.w400,
                color: AppColor.borderColor,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ChannelChatProvider>(
        builder: (context, channelChatProvider, child) {
          final messages = channelChatProvider.filesListingInChannelChatModel?.data?.messages;

          return messages?.length == 0 ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImage.fileIcon,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,height: 100,width: 100,),
                SizedBox(height: 10),
                Cw.commonText(text: "No file posts yet",fontSize: 18),
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
                    child: Cw.commonText(
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
                        String originalFileName = Cf.instance.getFileName(fileUrl);
                        String formattedFileName = Cf.instance.formatFileName(originalFileName);
                        String fileType = Cf.instance.getFileExtension(originalFileName);
                        bool isAudioFile = fileType.toLowerCase() == 'm4a' ||
                            fileType.toLowerCase() == 'mp3' ||
                            fileType.toLowerCase() == 'wav';
                        if (isAudioFile) {
                          // print("Rendering Audio Player for: ${ApiString.profileBaseUrl}$filesUrl");
                          return Padding(
                            padding: const EdgeInsets.only(left: 15,right: 15, top: 5),
                            child: AudioPlayerWidget(
                              audioUrl: fileUrl,
                              audioPlayers: _audioPlayers,
                              audioDurations: _audioDurations,
                              onPlaybackStart: _handleAudioPlayback,
                              currentlyPlayingPlayer: _currentlyPlayingPlayer,
                              isForwarded: true,
                            ),
                          );
                        }
                        return Container(
                          margin: EdgeInsets.only(top: 7, right: 15,left: 15),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColor.lightGreyColor),
                          ),
                          child: Row(
                            children: [
                              Cf.instance.getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$fileUrl"),
                              SizedBox(width: 20),
                              Cw.commonText(text: formattedFileName, maxLines: 1,overflow: TextOverflow.ellipsis),
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