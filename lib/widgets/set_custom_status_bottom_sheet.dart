// import 'package:e_connect/main.dart';
// import 'package:e_connect/utils/app_string_constants.dart';
// import 'package:e_connect/utils/common/common_function.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
//
// import '../utils/app_color_constants.dart';
// import '../utils/common/common_widgets.dart';
//
// void showCustomStatusSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     builder: (context) => const CustomStatusSheet(),
//   );
// }
//
// class CustomStatusSheet extends StatelessWidget {
//   const CustomStatusSheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.9,
//       ),
//       decoration: BoxDecoration(
//         color: AppColor.commonAppColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           _buildHeader(context),
//
//           // Custom Status Input
//           _buildCustomStatusInput(),
//
//           // Suggestions Section
//           _buildSuggestionsSection(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.white.withOpacity(0.1),
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: Icon(
//               Icons.close,
//               color: Colors.white.withOpacity(0.8),
//               size: 24,
//             ),
//           ),
//           commonText(
//             text: 'Set a custom status',
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//           TextButton(
//             onPressed: () {
//               // Handle done action
//               Navigator.pop(context);
//             },
//             child: commonText(
//               text: 'DONE',
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCustomStatusInput() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           GestureDetector(
//           onTap: () => showEmojiSheet(),
//             child: Icon(
//               Icons.sentiment_satisfied_alt,
//               color: Colors.white.withOpacity(0.8),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: TextField(
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Set a custom status',
//                 hintStyle: TextStyle(
//                   color: Colors.white.withOpacity(0.5),
//                   fontSize: 16,
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSuggestionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: commonText(
//             text: 'SUGGESTIONS',
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.white.withOpacity(0.5),
//           ),
//         ),
//         _buildSuggestionItem(
//           icon: Icons.calendar_today,
//           title: AppString.inMeeting,
//         ),
//         _buildSuggestionItem(
//           icon: Icons.lunch_dining,
//           title: AppString.outForLunch,
//         ),
//         _buildSuggestionItem(
//           icon: Icons.sick,
//           title: AppString.outSick,
//         ),
//         _buildSuggestionItem(
//           icon: Icons.home_work,
//           title: AppString.workingFromHome,
//         ),
//         _buildSuggestionItem(
//           icon: Icons.beach_access,
//           title: AppString.onVacation,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSuggestionItem({
//     required IconData icon,
//     required String title,
//   }) {
//     return InkWell(
//       onTap: () {
//         print("SUGESTIONS>>>> $title");
//         pop();
//         commonCubit.updateCustomStatusCall(status: title,emojiUrl: "https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/1f60e.png");
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: Colors.white.withOpacity(0.8),
//               size: 24,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   commonText(
//                     text: title,
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Future showEmojiSheet(){
//   return showModalBottomSheet(
//     context: navigatorKey!.currentState!.context,
//     builder: (BuildContext subcontext) {
//       return EmojiPicker(
//           onEmojiSelected: (category, emoji) {
//             print("emojisss >> ${emoji.emoji}");
//             print("emojisss >> ${emoji.name}");
//           }
//        );
// });}
//
//
// ///
