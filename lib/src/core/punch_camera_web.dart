import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../l10n/app_localizations.dart';

/// Browser camera: a live preview of the front camera and one frame captured on tap. There is
/// no file chooser, so only a picture taken now can be sent with the mark.
Future<Uint8List?> capturePunchPhoto(BuildContext context) =>
    showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _WebCameraDialog(),
    );

int _views = 0;

class _WebCameraDialog extends StatefulWidget {
  const _WebCameraDialog();

  @override
  State<_WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<_WebCameraDialog> {
  final web.HTMLVideoElement _video = web.HTMLVideoElement();
  late final String _viewType = 'pulse-camera-${_views++}';
  web.MediaStream? _stream;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _video
      ..autoplay = true
      ..muted = true
      ..setAttribute('playsinline', 'true');
    _video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..transform = 'scaleX(-1)';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => _video,
    );
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(
            web.MediaStreamConstraints(
              video: {
                'facingMode': 'user',
                'width': {'ideal': 960},
                'height': {'ideal': 960},
              }.jsify()!,
              audio: false.toJS,
            ),
          )
          .toDart;
      if (!mounted) {
        _stop(stream);
        return;
      }
      _stream = stream;
      _video.srcObject = stream;
      await _video.play().toDart;
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _stop(web.MediaStream? stream) {
    for (final track
        in stream?.getTracks().toDart ?? <web.MediaStreamTrack>[]) {
      track.stop();
    }
  }

  @override
  void dispose() {
    _stop(_stream);
    _video.srcObject = null;
    super.dispose();
  }

  /// One frame of the stream as a JPEG of at most 960 px on the longer side.
  Uint8List? _frame() {
    final width = _video.videoWidth;
    final height = _video.videoHeight;
    if (width == 0 || height == 0) return null;
    final scale = 960 / (width > height ? width : height);
    final factor = scale < 1 ? scale : 1.0;
    final canvas = web.HTMLCanvasElement()
      ..width = (width * factor).round()
      ..height = (height * factor).round();
    final context = canvas.getContext('2d')! as web.CanvasRenderingContext2D;
    context.drawImage(_video, 0, 0, canvas.width, canvas.height);
    final url = canvas.toDataURL('image/jpeg', 0.7.toJS);
    final comma = url.indexOf(',');
    if (comma < 0) return null;
    final bytes = base64Decode(url.substring(comma + 1));
    return bytes.isEmpty ? null : bytes;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      key: const Key('webCameraDialog'),
      title: Text(l.takePhoto),
      content: SizedBox(
        width: 320,
        height: 320,
        child: _failed
            ? Center(
                child: Text(
                  l.cameraUnavailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    HtmlElementView(viewType: _viewType),
                    if (!_ready)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton.icon(
          key: const Key('captureWebPhoto'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _ready ? () => Navigator.of(context).pop(_frame()) : null,
          icon: const Icon(Icons.photo_camera),
          label: Text(l.capturePhoto),
        ),
      ],
    );
  }
}
