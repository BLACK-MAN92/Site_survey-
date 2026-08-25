import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Why the camera could not be opened, so the UI can offer the right way out
/// instead of leaving the engineer on a spinner that never resolves.
enum CameraFailure {
  permissionDenied,
  permissionPermanentlyDenied,
  noCamera,
  initFailed,
}

/// Full-screen capture view.
///
/// Pops with the captured file path (`String`), or `null` if the engineer
/// backed out.
class CameraOverlayScreen extends StatefulWidget {
  /// Path of the matching before-photo, ghosted over the preview so the
  /// after-photo can be framed from the same angle.
  final String? beforePhotoPath;

  /// Shown in the app bar so the engineer knows which work item they are
  /// documenting.
  final String? title;

  const CameraOverlayScreen({super.key, this.beforePhotoPath, this.title});

  @override
  State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraFailure? _failure;
  String? _failureDetail;
  bool _starting = true;

  /// Guards against a second shutter tap while the first is still writing.
  bool _capturing = false;

  /// Ghost overlay strength. Adjustable because a bright before-photo can wash
  /// out the live preview at a fixed opacity.
  double _overlayOpacity = 0.4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// The OS reclaims the camera when the app goes to the background. Without
  /// releasing and rebuilding the controller the preview comes back frozen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (controller != null) {
        _controller = null;
        controller.dispose();
        if (mounted) setState(() {});
      }
      return;
    }

    if (state == AppLifecycleState.resumed && controller == null && !_starting) {
      _start();
    }
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _failure = null;
      _failureDetail = null;
    });

    // Android 6+ grants CAMERA at runtime. Declaring it in the manifest only
    // makes the request possible; skipping the request meant initialize() threw
    // CameraAccessDenied and, with nothing catching it, the screen sat on a
    // spinner forever.
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isPermanentlyDenied || status.isRestricted) {
      return _fail(CameraFailure.permissionPermanentlyDenied);
    }
    if (!status.isGranted) {
      return _fail(CameraFailure.permissionDenied);
    }

    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      return _fail(CameraFailure.initFailed, e.description ?? e.code);
    }
    if (!mounted) return;

    if (cameras.isEmpty) {
      return _fail(CameraFailure.noCamera);
    }

    // Survey evidence is shot with the rear camera; index 0 is the front one on
    // some devices, which would silently produce useless photos.
    final description = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      description,
      ResolutionPreset.veryHigh,
      // No audio is ever recorded here, and leaving it on makes the plugin ask
      // for a microphone permission the app does not declare.
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      await controller.dispose();
      if (!mounted) return;
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt') {
        return _fail(CameraFailure.permissionPermanentlyDenied);
      }
      return _fail(CameraFailure.initFailed, e.description ?? e.code);
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _starting = false;
    });
  }

  void _fail(CameraFailure failure, [String? detail]) {
    if (!mounted) return;
    setState(() {
      _failure = failure;
      _failureDetail = detail;
      _starting = false;
      _controller = null;
    });
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not take the photo: ${e.description ?? e.code}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failure != null) {
      return _buildFailure(_failure!);
    }

    final controller = _controller;
    if (_starting || controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Starting camera…', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
          ),

          if (widget.beforePhotoPath != null)
            // IgnorePointer so the ghost image cannot swallow shutter taps.
            IgnorePointer(
              child: Opacity(
                opacity: _overlayOpacity,
                child: Image.file(
                  File(widget.beforePhotoPath!),
                  fit: BoxFit.contain,
                  // A missing before-photo must not take the whole screen down.
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

          if (widget.title != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                ),
              ),
            ),

          if (widget.beforePhotoPath != null)
            Positioned(
              bottom: 120,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  const Icon(Icons.layers, color: Colors.white70, size: 20),
                  Expanded(
                    child: Slider(
                      value: _overlayOpacity,
                      min: 0,
                      max: 0.8,
                      onChanged: (v) => setState(() => _overlayOpacity = v),
                    ),
                  ),
                ],
              ),
            ),

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
                  onPressed: _capturing ? null : _capture,
                  child: _capturing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt, color: Colors.black),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailure(CameraFailure failure) {
    late final String message;
    late final String actionLabel;
    late final VoidCallback action;

    switch (failure) {
      case CameraFailure.permissionDenied:
        message = 'Camera access is needed to record site evidence.';
        actionLabel = 'Grant access';
        action = _start;
        break;
      case CameraFailure.permissionPermanentlyDenied:
        message = 'Camera access was turned off for this app. Enable it in '
            'Settings › Permissions › Camera, then come back.';
        actionLabel = 'Open settings';
        action = openAppSettings;
        break;
      case CameraFailure.noCamera:
        message = 'No camera was found on this device. Survey photos have to '
            'be taken on a device with a working camera.';
        actionLabel = 'Go back';
        action = () => Navigator.of(context).pop();
        break;
      case CameraFailure.initFailed:
        message = 'The camera could not be started.'
            '${_failureDetail != null ? '\n\n$_failureDetail' : ''}'
            '\n\nClose any other app using the camera and try again.';
        actionLabel = 'Try again';
        action = _start;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: action, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
