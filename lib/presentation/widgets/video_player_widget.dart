// lib/presentation/screens/dashboard/video_player_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_zone/presentation/widgets/watermark_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../services/secure_service.dart';

// Corrected package-relative imports

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Print the video ID to the console to make sure it's correct.
    debugPrint("Attempting to play video with ID: ${widget.videoId}");

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        forceHD: true,
        // It's good practice to hide the fullscreen button when using security overlays,
        // as it can sometimes create a new window that bypasses them.
        showLiveFullscreenButton: false,
      ),
    );
    // Use our dedicated service to secure the screen
    ///SecureService.secureScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    // Use our service to unsecure the screen when the user leaves
    /// SecureService.unsecureScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Video Lesson")),
      // Use YoutubePlayerBuilder for a more robust build process.
      // This ensures the UI waits for the player to be ready.
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wrap the player in an AspectRatio to give it a defined size.
              AspectRatio(
                aspectRatio: 16 / 9,
                // Stack allows us to overlay the watermark on the player.
                child: Stack(
                  children: [
                    player, // This is the actual YoutubePlayer widget from the builder.
                    // Use our reusable WatermarkWidget
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is Authenticated) {
                          return WatermarkWidget(text: state.userModel.email);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'For your security, screenshots and screen recording are disabled for this content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}