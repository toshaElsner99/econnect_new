import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CameraScreen extends StatefulWidget {
  final String screenName;
  const CameraScreen({super.key,required this.screenName});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isRecording = false;
  bool _isVideoMode = false;
  FlashMode _flashMode = FlashMode.auto;
  File? _capturedImage;
  File? _capturedVideo;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoPlaying = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  List<AssetEntity> _recentAssets = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  bool _showingPhotos = true; // true for Photos tab, false for Albums tab
  bool _isRearCamera = true; // Track current camera

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
    _loadGallery();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadGallery();
    }
  }

  Future<void> _loadGallery() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (permitted.isAuth || permitted.hasAccess) {
      await _loadAlbums();
    }
  }

  Future<void> _loadAlbums() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      
      if (mounted) {
        setState(() {
          _albums = albums;
          _selectedAlbum = albums.firstWhere(
            (album) => album.isAll,
            orElse: () => albums.first,
          );
        });
        await _loadAssetsForCurrentAlbum();
      }
    } catch (e) {
      print("Error loading albums: $e");
    }
  }

  Future<void> _loadAssetsForCurrentAlbum() async {
    if (_selectedAlbum == null) return;
    
    try {
      final assets = await _selectedAlbum!.getAssetListRange(
        start: 0,
        end: 50,
      );
      
      if (mounted) {
        setState(() {
          _recentAssets = assets;
        });
      }
    } catch (e) {
      print("Error loading assets: $e");
    }
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      double minZoom = await _cameraController!.getMinZoomLevel();
      await _cameraController!.setZoomLevel(minZoom); // Set to minimum zoom

      if (mounted) setState(() {});
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += Duration(seconds: 1);
        if (_recordingDuration.inMinutes >= 3) {
          stopVideoRecording();
        }
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingDuration = Duration.zero;
  }

  Future<void> capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final XFile file = await _cameraController!.takePicture();
    setState(() {
      _capturedImage = File(file.path);
    });
  }

  Future<void> startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final dir = await getTemporaryDirectory();
    final String filePath = "${dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4";

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _startRecordingTimer();
    } catch (e) {
      print("Error starting video recording: $e");
    }
  }

  Future<void> stopVideoRecording() async {
    if (!_isRecording) return;

    try {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      _stopRecordingTimer();

      setState(() {
        _isRecording = false;
        _capturedVideo = File(videoFile.path);
      });

      // Initialize video player for preview
      _videoPlayerController = VideoPlayerController.file(_capturedVideo!)
        ..initialize().then((_) {
          setState(() {});
        });
    } catch (e) {
      print("Error stopping video recording: $e");
    }
  }

  void toggleMode() {
    if (_isRecording) return; // Don't allow mode switch while recording
    setState(() {
      _isVideoMode = !_isVideoMode;
      _capturedImage = null;
      _capturedVideo = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  void clearCapture() {
    setState(() {
      _capturedImage = null;
      _capturedVideo = null;
      if (_videoPlayerController != null) {
        _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }
    });
  }

  void saveAndExit() {
    if (_capturedImage != null || _capturedVideo != null) {
      final File fileToUse = _capturedImage ?? _capturedVideo!;
      final String extension = fileToUse.path.split('.').last;
      final String fileName = fileToUse.path.split('/').last;

      final platformFile = PlatformFile(
        path: fileToUse.path,
        name: fileName,
        size: fileToUse.lengthSync(),
        bytes: fileToUse.readAsBytesSync(),
      );

      FileServiceProvider.instance.addFilesForScreen(widget.screenName, [platformFile]);
    }
    Navigator.pop(context);
  }

  void toggleVideoPlayback() {
    if (_videoPlayerController != null) {
      setState(() {
        if (_videoPlayerController!.value.isPlaying) {
          _videoPlayerController!.pause();
        } else {
          _videoPlayerController!.play();
        }
        _isVideoPlaying = _videoPlayerController!.value.isPlaying;
      });
    }
  }

  void toggleFlash() {
    setState(() {
      if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.off;
      } else if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.torch;
      } else {
        _flashMode = FlashMode.auto;
      }
      _cameraController?.setFlashMode(_flashMode);
    });
  }

  IconData getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.torch:
        return Icons.highlight;
      }
  }

  Future<void> switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    
    final newCameraIndex = _isRearCamera ? 1 : 0;
    final newCamera = cameras![newCameraIndex];
    
    // Dispose of previous controller
    final previousController = _cameraController;
    await _cameraController?.dispose();
    
    // Create new controller
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    // If old controller is mounted, wait until it's disposed
    if (previousController?.value.isInitialized ?? false) {
      await previousController!.dispose();
    }
    
    // Initialize new controller
    await _cameraController!.initialize();
    
    if (mounted) {
      setState(() {
        _isRearCamera = !_isRearCamera;
      });
    }
  }

  Future<void> _openAssetPicker() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 5, // Allow up to 5 selections
        requestType: RequestType.common,
        specialPickerType: SpecialPickerType.noPreview,
        themeColor: Theme.of(context).primaryColor,
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        List<PlatformFile> selectedFiles = [];
        
        for (var asset in result) {
          final File? file = await asset.file;
          if (file != null) {
            final platformFile = PlatformFile(
              path: file.path,
              name: file.path.split('/').last,
              size: file.lengthSync(),
              bytes: file.readAsBytesSync(),
            );
            selectedFiles.add(platformFile);
          }
        }
        
        if (selectedFiles.isNotEmpty) {
          FileServiceProvider.instance.addFilesForScreen(
            widget.screenName, 
            selectedFiles
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print("Error selecting media: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select media'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 35,
        backgroundColor: Colors.black,
        leading: Cw.instance.commonBackButton(),
        centerTitle: true,
        title: Visibility(
          visible: _isVideoMode,
          child: Cw.instance.commonText(text: "3:00", color: Colors.white)
        ),
        actions: [
          if (cameras != null && cameras!.length > 1)
            IconButton(
              icon: Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
              ),
              onPressed: switchCamera,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_capturedImage == null && _capturedVideo == null) ...[
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     commonBackButton(),
              //
              //   ],
              // ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Transform.scale(
                    scaleX: !_isRearCamera ? Platform.isAndroid ? -1 : 1 : 1,
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
              ),

              // Recording Duration
              if (_isRecording)
                Container(
                  padding: EdgeInsets.only(bottom: 0,top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              // Camera Controls
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isVideoMode ? Icons.camera_alt : Icons.videocam,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: toggleMode,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: GestureDetector(
                            onTap: _isVideoMode
                              ? (_isRecording ? stopVideoRecording : startVideoRecording)
                              : capturePhoto,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  padding: EdgeInsets.all(!_isVideoMode ? 7 : 15),
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    color: _isRecording ? Colors.red : Colors.transparent,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isRecording ? Colors.transparent : Colors.white
                                    ),
                                  ),
                                ),
                                Cw.instance.commonText(text: !_isVideoMode ? "CAPTURE" : "RECORD",color: Colors.white,fontSize: 13)
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(getFlashIcon(), color: Colors.white, size: 30),
                          onPressed: toggleFlash,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _openAssetPicker,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Media Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: _capturedImage != null
                    ? Image.file(
                        _capturedImage!,
                        fit: BoxFit.contain,
                      )
                    : _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          )
                        : Container(),
                ),
              ),

              // Preview Controls
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: clearCapture,
                    ),
                    if (_capturedVideo != null)
                      IconButton(
                        icon: Icon(
                          _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: toggleVideoPlayback,
                      ),
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.white, size: 30),
                      onPressed: saveAndExit,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
