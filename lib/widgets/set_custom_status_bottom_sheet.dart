import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/app_color_constants.dart';
import '../utils/common/common_widgets.dart';

void showCustomStatusSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const CustomStatusSheet(),
  );
}

class CustomStatusSheet extends StatelessWidget {
  const CustomStatusSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColor.commonAppColor,
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
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
          commonText(
            text: 'Set a custom status',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          TextButton(
            onPressed: () {
              commonCubit.updateCustomStatusCall(status: commonCubit.setCustomTextController.text,emojiUrl: getEmojiAndText());
              Navigator.pop(context);
            },
            child: commonText(
              text: 'DONE',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  getEmojiAndText({bool image = true}){
    if(commonCubit.selectedIndexOfStatus == 0){
      return image ? AppImage.inMeetingUrl : AppString.inMeeting;
    }else if(commonCubit.selectedIndexOfStatus == 1){
      return image ? AppImage.outForLunchUrl : AppString.outForLunch;
    }else if(commonCubit.selectedIndexOfStatus == 2){
      return image ? AppImage.outSickUrl : AppString.outSick;
    }else if(commonCubit.selectedIndexOfStatus == 3){
      return image ? AppImage.workingFromHomeUrl : AppString.workingFromHome;
    }else if(commonCubit.selectedIndexOfStatus == 4){
      return image ? AppImage.onVacationUrl : AppString.onVacation;
    }else if(commonCubit.customStatusUrl.isNotEmpty){
      return commonCubit.customStatusUrl;
    }
  }

  Widget _buildCustomStatusInput() {
    return BlocBuilder(
      bloc: commonCubit,
      builder: (context, state) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => showEmojiSheet(),
              child: (commonCubit.customStatusUrl.isNotEmpty || commonCubit.selectedIndexOfStatus != null) ? Image.network(getEmojiAndText(),height: 24,width: 24,) : Icon(
                Icons.sentiment_satisfied_alt,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: commonTextFormField(
                controller: commonCubit.setCustomTextController, hintText: 'Set a custom status',
                suffixIcon: (commonCubit.customStatusUrl.isNotEmpty) ? GestureDetector(
                  onTap: () => commonCubit.selectedIndexOfStatus != null ? commonCubit.clearUpdates() : commonCubit.updateCustomStatusCall(status: "", emojiUrl: ""),
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
          ],
        ),
      );
    },);
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: commonText(
            text: 'SUGGESTIONS',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
          ),
        ),

        _buildSuggestionItem(
          icon: AppImage.inMeetingUrl,
          title: AppString.inMeeting,
          index: 0,
        ),
        _buildSuggestionItem(
          icon: AppImage.outForLunchUrl,
          title: AppString.outForLunch,
          index: 1,
        ),
        _buildSuggestionItem(
          icon: AppImage.outSickUrl,
          title: AppString.outSick,
          index: 2,
        ),
        _buildSuggestionItem(
          icon: AppImage.workingFromHomeUrl,
          title: AppString.workingFromHome,
          index: 3,
        ),
        _buildSuggestionItem(
          icon: AppImage.onVacationUrl,
          title: AppString.onVacation,
          index: 4
        ),
      ],
    );
  }

  Widget _buildSuggestionItem({
    required String icon,
    required String title,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        print("SUGESTIONS>>>> $title");
        commonCubit.updateIndexForCustomStatus(index,title);
        // pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Image.network(icon,height: 24,width: 24,),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonText(
                    text: title,
                    fontSize: 16,
                    color: Colors.white,
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
    context: navigatorKey!.currentState!.context,
    builder: (BuildContext subcontext) {
      return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            print("emojisss >> ${emoji.emoji}");
            print("emojisss >> ${emoji.name}");
          }
       );
});}


///
