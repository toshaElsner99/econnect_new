import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:e_connect/utils/common/common_function.dart';

class MediaPreviewScreen extends StatelessWidget {
  final List<PlatformFile> files;
  final int initialIndex;

  const MediaPreviewScreen({
    super.key,
    required this.files,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blackColor,
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: commonText(
          text: '${initialIndex + 1} of ${files.length}',
          fontSize: 16,
          color: AppColor.whiteColor,
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final isImage = ['jpg', 'jpeg', 'png', 'gif']
                  .contains(file.extension?.toLowerCase());

              if (isImage) {
                return Center(
                  child: Image.file(
                    File(file.path!),
                    fit: BoxFit.contain,
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        color: AppColor.commonAppColor,
                        child: getFileIcon(file.extension!, file.path),
                      ),
                      const SizedBox(height: 16),
                      commonText(
                        text: file.name,
                        fontSize: 16,
                        color: AppColor.whiteColor,
                      ),
                    ],
                  ),
                );
              }
            },
            onPageChanged: (index) {
              // Update the title with current position
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.appBarColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade800,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColor.lightBlueColor,
                        radius: 15,
                        child: commonText(
                          text: 'T',
                          color: AppColor.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      commonText(
                        text: 'Tosha Shah (you)',
                        color: AppColor.whiteColor,
                        fontSize: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  commonText(
                    text: 'Shared in @jigarghodasara',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 