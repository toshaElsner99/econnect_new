import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

// class FileServiceProvider with ChangeNotifier{
//   static final FileServiceProvider instance = FileServiceProvider._internal();
//   factory FileServiceProvider() => instance;
//   FileServiceProvider._internal();
//
//   final List<PlatformFile> _selectedFiles = [];
//   final ImagePicker _picker = ImagePicker();
//
//   List<PlatformFile> get selectedFiles => _selectedFiles;
//
//   Future<void> pickFiles() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.any,
//     );
//
//     if (result != null) {
//       _selectedFiles.addAll(result.files);
//     }
//     notifyListeners();
//   }
//
//   void removeFile(int index) {
//     _selectedFiles.removeAt(index);
//     notifyListeners();
//   }
//
//   void clearFiles() {
//     _selectedFiles.clear();
//     notifyListeners();
//   }
//
//   Future<void> pickImages() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
//         allowMultiple: true,
//       );
//
//       if (result != null) {
//         selectedFiles.addAll(result.files);
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error picking images: $e');
//     }
//   }
//
//   Future<void> captureMedia({required bool isVideo}) async {
//     try {
//       final XFile? media = isVideo
//           ? await _picker.pickVideo(source: ImageSource.camera)
//           : await _picker.pickImage(source: ImageSource.camera);
//
//       if (media != null) {
//         final file = PlatformFile(
//           name: media.name,
//           size: await media.length(),
//           path: media.path,
//         );
//         _selectedFiles.add(file);
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error capturing media: $e');
//     }
//   }
// }
class FileServiceProvider with ChangeNotifier {
  static final FileServiceProvider instance = FileServiceProvider._internal();
  factory FileServiceProvider() => instance;
  FileServiceProvider._internal();

  final Map<String, List<PlatformFile>> _screenFiles = {}; // Store files by screen

  List<PlatformFile> getFilesForScreen(String screenName) {
    return _screenFiles[screenName] ?? []; // Return files for specific screen
  }

  void addFilesForScreen(String screenName, List<PlatformFile> files) {
    if (_screenFiles.containsKey(screenName)) {
      _screenFiles[screenName]!.addAll(files); // Add files for the screen
    } else {
      _screenFiles[screenName] = files; // Initialize new list for screen
    }
    notifyListeners();
  }

  void removeFile(String screenName, int index) {
    _screenFiles[screenName]?.removeAt(index);
    notifyListeners();
  }

  void clearFilesForScreen(String screenName) {
    if(getFilesForScreen(screenName).isNotEmpty){
      _screenFiles[screenName]?.clear();
      notifyListeners();
    }
  }

  Future<void> pickFiles(String screenName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      addFilesForScreen(screenName, result.files);
    }
  }

  Future<void> pickImages(String screenName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        // allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: true,
      );

      if (result != null) {
        addFilesForScreen(screenName, result.files);
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> captureMedia({required bool isVideo, required String screenName}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? media = isVideo
          ? await picker.pickVideo(source: ImageSource.camera)
          : await picker.pickImage(source: ImageSource.camera);

      if (media != null) {
        final file = PlatformFile(
          name: media.name,
          size: await media.length(),
          path: media.path,
        );
        addFilesForScreen(screenName, [file]); // Add captured media to the correct screen
      }
    } catch (e) {
      debugPrint('Error capturing media: $e');
    }
  }
}
