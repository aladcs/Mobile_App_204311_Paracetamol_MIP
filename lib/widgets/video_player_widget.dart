/*
 * File: video_player_widget.dart
 * Feature : Core Feature
 * Description: A versatile video player widget supporting local assets and network URLs.
 *
 * Responsibilities:
 * - Handle video playback from local assets and remote URLs
 * - Provide interactive video controls and thumbnails
 * - Manage video initialization and error states
 * - Support both full player and thumbnail modes
 *
 * Dependencies:
 * - None
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// The [VideoPlayerWidget] class represents a video playback widget that supports local and remote URLs.
///
/// Fields:
/// - videoPath: The absolute or relative path to a local asset
/// - videoUrl: The fully qualified URL to a remote video stream
/// - isThumbnail: Constrains the player to a static, non-interactive thumbnail
///
/// Usage:
/// - Handle video playback from local assets and remote URLs
/// - Provide interactive video controls and thumbnails
/// - Manage video initialization and error states
/// - Support both full player and thumbnail modes
class VideoPlayerWidget extends StatefulWidget {
  final String? videoPath;
  final String? videoUrl;
  final bool isThumbnail;

  /// Creates a [VideoPlayerWidget] with the specified video source configuration.
  ///
  /// The [videoPath] optionally specifies a local asset path, [videoUrl] optionally
  /// provides a remote video URL, and [isThumbnail] determines whether the widget
  /// should display as a static thumbnail or interactive player.
  const VideoPlayerWidget({
    Key? key,
    this.videoPath,
    this.videoUrl,
    this.isThumbnail = false,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // Asynchronously sets up the video controller with the appropriate source.
  Future<void> _initializePlayer() async {
    try {
      // Prioritizes network URL over local file path.
      if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl!),
        );
      } else if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
        _controller = VideoPlayerController.asset(widget.videoPath!);
      } else {
        setState(() {
          _hasError = true;
        });
        return;
      }

      await _controller!.initialize();
      if (!widget.isThumbnail) {
        _controller!.setLooping(true); // Loop
      }
      _controller!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      print('Error initializing video: $e');
    }
  }
  // Reverses the current play/pause state.
  void _togglePlayPause() {
    if (_controller == null) return;
    
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted && _controller!.value.isPlaying) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    });
  }
  // Handles user taps on the interactive video area.
  void _onTap() {
    setState(() {
      _showControls = true;
    });
    _togglePlayPause();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.isThumbnail
        ? BorderRadius.circular(20)
        : BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          );

    if (_hasError) {
      return Container(
        height: widget.isThumbnail ? null : 280,
        decoration: BoxDecoration(
          color: Color(0xFF6EE7B7),
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: widget.isThumbnail ? 30 : 60, color: Colors.black38),
              if (!widget.isThumbnail) ...[
                SizedBox(height: 12),
                Text(
                  'Video not available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        height: widget.isThumbnail ? null : 280,
        decoration: BoxDecoration(
          color: Color(0xFF6EE7B7),
          borderRadius: borderRadius,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: widget.isThumbnail ? 2 : 4,
          ),
        ),
      );
    }

    final playerUI = Container(
      height: widget.isThumbnail ? null : 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
            alignment: Alignment.center,
            children: [
              // Video Player
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
              
              // Play/Pause Button Overlay (hide in thumbnail mode)
              if (!widget.isThumbnail && (!_controller!.value.isPlaying || _showControls))
                AnimatedOpacity(
                  opacity: (!_controller!.value.isPlaying || _showControls) ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

    if (widget.isThumbnail) {
      return playerUI; 
    }

    return GestureDetector(
      onTap: _onTap,
      child: playerUI,
    );
  }
}
