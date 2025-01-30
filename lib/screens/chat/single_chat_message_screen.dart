import 'dart:io';

import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';

import '../../widgets/chat_profile_header.dart';
import '../../screens/chat/media_preview_screen.dart';

class SingleChatScreen extends StatefulWidget {
  const SingleChatScreen({super.key});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  String? lastSentMessage;
  List<dynamic>? _lastSentDelta;
  bool _showToolbar = false;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonText(
              text: 'Tosha Shah',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.whiteColor,
            ),
            commonText(
              text: 'View info >',
              fontSize: 12,
              color: AppColor.whiteColor,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
            onPressed: () {
              showChatSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const ChatProfileHeader(),

                  Divider(
                    color: Colors.grey.shade800,
                    height: 1,
                  ),

                  messages() // Minimum height for empty state
                ],
              ),
            ),
          ),

          // Bottom text editor (keep outside scrollview)
          inputTextFieldWithEditor()
        ],
      ),
    );
  }

  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _showToolbar = false;
    });
    // FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    // _focusNode.addListener(() {
    //   if (!_focusNode.hasFocus) {
    //     setState(() {
    //       _showToolbar = false;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildFormattedText(String text, List<dynamic> deltaOps) {
    return quill.QuillEditor(
      controller: quill.QuillController(
        document: quill.Document.fromJson(deltaOps),
        selection: const TextSelection.collapsed(offset: 0),
      ),
      scrollController: ScrollController(),
      configurations: quill.QuillEditorConfigurations(
        checkBoxReadOnly: true,
        autoFocus: false,
        showCursor: false,
        padding: EdgeInsets.zero,
        scrollable: false,
        customStyles: const quill.DefaultStyles(
          paragraph: quill.DefaultTextBlockStyle(
            TextStyle(
              color: AppColor.whiteColor,
              fontSize: 16,
            ),
            quill.HorizontalSpacing.zero,
            quill.VerticalSpacing.zero,
            quill.VerticalSpacing.zero,
            BoxDecoration(color: Colors.transparent),
          ),
          quote: quill.DefaultTextBlockStyle(
            TextStyle(
              color: AppColor.whiteColor,
              fontSize: 16,
            ),
            quill.HorizontalSpacing(16, 0),
            quill.VerticalSpacing(8, 0),
            quill.VerticalSpacing(8, 0),
            BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColor.whiteColor,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
      ),
      focusNode: FocusNode(),
    );
  }

  Widget messages() {
    // Message display area
    if (lastSentMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: _buildFormattedText(
            lastSentMessage!,
            _lastSentDelta ?? [],
          ),
        ),
      );
    } else {
      return const SizedBox(height: 200);
    }
  }

  Widget inputTextFieldWithEditor() {
    return Container(
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
        children: [
          if (_showToolbar)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    sharedConfigurations: const quill.QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                    showDividers: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: false,
                    showStrikeThrough: true,
                    showInlineCode: true,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showHeaderStyle: true,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: false,
                    showCodeBlock: true,
                    showQuote: true,
                    showIndent: false,
                    showLink: true,
                    showUndo: false,
                    showRedo: false,
                    showSearchButton: false,
                    showClipboardCut: false,
                    showClipboardCopy: false,
                    showClipboardPaste: false,
                    multiRowsDisplay: false,
                    showSubscript: false,
                    showSuperscript: false),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: _showToolbar ? Colors.blue : AppColor.whiteColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showToolbar = !_showToolbar;
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: quill.QuillEditor(
                        controller: _controller,
                        focusNode: _focusNode,
                        scrollController: ScrollController(),
                        configurations: quill.QuillEditorConfigurations(
                          scrollable: true,
                          autoFocus: false,
                          checkBoxReadOnly: false,
                          placeholder: 'Write to Tosha Shah',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          maxHeight: 100,
                          minHeight: 40,
                          customStyles: const quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 16,
                                ),
                                quill.HorizontalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                BoxDecoration(color: Colors.transparent)),
                            placeHolder: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                quill.HorizontalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                BoxDecoration(color: Colors.transparent)),
                            quote: quill.DefaultTextBlockStyle(
                              TextStyle(
                                color: AppColor.whiteColor,
                                fontSize: 16,
                              ),
                              quill.HorizontalSpacing(16, 0),
                              quill.VerticalSpacing(8, 0),
                              quill.VerticalSpacing(8, 0),
                              BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: AppColor.whiteColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          selectedFilesWidget(),
          fileSelectionAndSendButtonRow()
        ],
      ),
    );
  }
  // File selected to send
  Widget selectedFilesWidget() {
    return Consumer<FileServiceProvider>(
      builder: (context, provider, _) {
        return Visibility(
          visible: provider.selectedFiles.isNotEmpty,
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.selectedFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaPreviewScreen(
                              files: provider.selectedFiles,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColor.commonAppColor,
                          child: getFileIcon(
                            provider.selectedFiles[index].extension!,
                            provider.selectedFiles[index].path,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          provider.removeFile(index);
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColor.blackColor,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColor.borderColor,
                            child: Icon(
                              Icons.close,
                              color: AppColor.blackColor,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showCameraOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              commonText(
                text: 'Camera Options',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.whiteColor,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Capture Photo',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Record Video',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget fileSelectionAndSendButtonRow() {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.alternate_email,
                color: AppColor.whiteColor),
            onPressed: () {},
          ),
          IconButton(
            icon:
            const Icon(Icons.attach_file, color: AppColor.whiteColor),
            onPressed: () {
              FileServiceProvider.instance.pickFiles();
            },
          ),
          IconButton(
            icon: const Icon(Icons.image, color: AppColor.whiteColor),
            onPressed: () {
              FileServiceProvider.instance.pickImages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColor.whiteColor),
            onPressed: () {
              showCameraOptionsBottomSheet(context);
            },
          ),
          GestureDetector(
            onTap: (){
              final plainText =
              _controller.document.toPlainText().trim();
              if (plainText.isNotEmpty) {
                setState(() {
                  lastSentMessage = plainText;
                  _lastSentDelta =
                      _controller.document.toDelta().toJson();
                });
                _clearInputAndDismissKeyboard();
              }
            },
            child: Container(
                decoration: BoxDecoration(
                    color: AppColor.lightBlueColor,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                  child: Icon(Icons.send,
                      color: AppColor.whiteColor),
                )
            ),
          ),
        ],
      ),
    );
  }
}
