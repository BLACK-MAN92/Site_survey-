import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraOverlayScreen extends StatefulWidget {
  final String? beforePhotoPath; // Pass this in for Post-Survey

  const CameraOverlayScreen({super.key, this.beforePhotoPath});

  @override
  State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) setState(() => _isReady = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Camera Preview
          CameraPreview(_controller!),

          // Ghost Overlay for Post-Survey
          if (widget.beforePhotoPath != null)
            Opacity(
              opacity: 0.4,
              child: Image.file(
                File(widget.beforePhotoPath!),
                fit: BoxFit.cover,
              ),
            ),
            
          // UI Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    final xFile = await _controller!.takePicture();
                    Navigator.of(context).pop(xFile.path);
                  },
                  child: const Icon(Icons.camera_alt, color: Colors.black),
                ),
                const SizedBox(width: 48), // Balance spacing
              ],
            ),
          )
        ],
      ),
    );
  }
}
