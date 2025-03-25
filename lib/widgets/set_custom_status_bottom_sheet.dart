import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/common_provider.dart';
import '../utils/app_color_constants.dart';
import '../utils/common/common_widgets.dart';

void showCustomStatusSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const CustomStatusSheet(),
    ),
  );
}

class CustomStatusSheet extends StatefulWidget {
  const CustomStatusSheet({super.key});

  @override
  State<CustomStatusSheet> createState() => _CustomStatusSheetState();
}

class _CustomStatusSheetState extends State<CustomStatusSheet> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommonProvider>().updatesCustomStatus();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Custom Status Input
            _buildCustomStatusInput(),

            // Suggestions Section
            _buildSuggestionsSection(),
            
            // Add extra padding at bottom for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColor.borderColor.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => pop(),
              icon: Icon(
                Icons.close,
                color: Colors.black.withOpacity(0.8),
                size: 24,
              ),
            ),
            commonText(
              text: 'Set a custom status',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            TextButton(
              onPressed: () {
                commonProvider.updateCustomStatusCall(status: commonProvider.setCustomTextController.text,emojiUrl: commonProvider.selectedIndexOfStatus == null ? "" : getEmojiAndText(commonProvider: commonProvider));
                Navigator.pop(context);
              },
              child: commonText(
                text: 'DONE',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    },);
  }

  getEmojiAndText({bool image = true,required CommonProvider commonProvider}){
    if(commonProvider.selectedIndexOfStatus == 0){
      return image ? AppImage.inMeetingUrl : AppString.inMeeting;
    }else if(commonProvider.selectedIndexOfStatus == 1){
      return image ? AppImage.outForLunchUrl : AppString.outForLunch;
    }else if(commonProvider.selectedIndexOfStatus == 2){
      return image ? AppImage.outSickUrl : AppString.outSick;
    }else if(commonProvider.selectedIndexOfStatus == 3){
      return image ? AppImage.workingFromHomeUrl : AppString.workingFromHome;
    }else if(commonProvider.selectedIndexOfStatus == 4){
      return image ? AppImage.onVacationUrl : AppString.onVacation;
    }else if(commonProvider.customStatusUrl.isNotEmpty){
      return commonProvider.customStatusUrl;
    }
  }

  Widget _buildCustomStatusInput() {
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              // onTap: () => showEmojiSheet(),
              child: (commonProvider.customStatusUrl.isNotEmpty || commonProvider.selectedIndexOfStatus != null) ? CachedNetworkImage(imageUrl: getEmojiAndText(commonProvider: commonProvider),height: 24,width: 24,) : Icon(
                Icons.sentiment_satisfied_alt,
                color: AppColor.borderColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: commonProvider.setCustomTextController,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
                decoration: InputDecoration(
                    hintText: 'Set a custom status',
                    suffixIcon: (commonProvider.customStatusTitle.isNotEmpty) ? GestureDetector(
                      onTap: () => commonProvider.selectedIndexOfStatus != null ? commonProvider.clearUpdates() : commonProvider.updateCustomStatusCall(status: "", emojiUrl: ""),
                      child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,size: 22,color: Colors.red,)),
                    ) : SizedBox.shrink()
                ),
              ),

              // child: commonTextFormField(
              //     controller: commonProvider.setCustomTextController, hintText: 'Set a custom status',
              //     suffixIcon: (commonProvider.customStatusUrl.isNotEmpty) ? GestureDetector(
              //       onTap: () => commonProvider.selectedIndexOfStatus != null ? commonProvider.clearUpdates() : commonProvider.updateCustomStatusCall(status: "", emojiUrl: ""),
              //       child: Container(
              //           margin: EdgeInsets.all(10),
              //           decoration: BoxDecoration(
              //             color: Colors.white,
              //             shape: BoxShape.circle,
              //           ),
              //           child: Icon(Icons.close,size: 22,color: Colors.red,)),
              //     ) : SizedBox.shrink()
              // ),
            ),
          ],
        ),
      );
    },);
  }

  Widget _buildSuggestionsSection() {
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: commonText(
              text: 'SUGGESTIONS',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          _buildSuggestionItem(
            commonProvider: commonProvider,
            icon: AppImage.inMeetingUrl,
            title: AppString.inMeeting,
            index: 0,
          ),
          _buildSuggestionItem(
            commonProvider: commonProvider,
            icon: AppImage.outForLunchUrl,
            title: AppString.outForLunch,
            index: 1,
          ),
          _buildSuggestionItem(
            commonProvider: commonProvider,
            icon: AppImage.outSickUrl,
            title: AppString.outSick,
            index: 2,
          ),
          _buildSuggestionItem(
            commonProvider: commonProvider,
            icon: AppImage.workingFromHomeUrl,
            title: AppString.workingFromHome,
            index: 3,
          ),
          _buildSuggestionItem(
              commonProvider: commonProvider,
              icon: AppImage.onVacationUrl,
              title: AppString.onVacation,
              index: 4
          ),
        ],
      );
    },);
  }

  Widget _buildSuggestionItem({
    required CommonProvider commonProvider,
    required String icon,
    required String title,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        print("SUGESTIONS>>>> $title");
        commonProvider.updateIndexForCustomStatus(index,title);
        // pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CachedNetworkImage(imageUrl: icon,height: 24,width: 24,),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonText(
                      text: title,
                      fontSize: 16,
                      color: Colors.black
                    // color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future showEmojiSheet(){
  return showModalBottomSheet(
      context: navigatorKey.currentState!.context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      isDismissible: true,
      builder: (BuildContext subcontext) {
        return SizedBox(
          height: MediaQuery.of(subcontext).size.height * 0.3,
          child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                print("emojisss >> ${emoji.emoji}");
                print("emojisss >> ${emoji.name}");
              }
          ),
        );
      }
  );
}


///
