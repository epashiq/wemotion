import 'package:flutter/material.dart';
import 'package:fourd_scrolling_video_to_vide_app/controller/provider/video_provider.dart';
import 'package:fourd_scrolling_video_to_vide_app/model/video_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReplyVideoWidget extends StatefulWidget {
  final VideoPost reply;
  final Function(String, String) onVideoInitialize;
  final Function(String) onTogglePlayback;
  final Function(String, bool) onVisibilityChanged;

  const ReplyVideoWidget({
    super.key,
    required this.reply,
    required this.onVideoInitialize,
    required this.onTogglePlayback,
    required this.onVisibilityChanged,
  });

  @override
  State<ReplyVideoWidget> createState() => _ReplyVideoWidgetState();
}

class _ReplyVideoWidgetState extends State<ReplyVideoWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    if (!_isInitialized) {
      await widget.onVideoInitialize(
          widget.reply.videoLink, widget.reply.identifier);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: VisibilityDetector(
        key: Key('reply_video_${widget.reply.identifier}'),
        onVisibilityChanged: (info) {
          final isVisible = info.visibleFraction > 0.3;
          widget.onVisibilityChanged(widget.reply.identifier, isVisible);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Consumer<VideoProvider>(
                builder: (context, provider, child) {
                  final controller =
                      provider.videoControllers[widget.reply.identifier];

                  if (controller == null || !controller.value.isInitialized) {
                    return Container(
                      height: double.infinity,
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () =>
                        widget.onTogglePlayback(widget.reply.identifier),
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  );
                },
              ),
              Consumer<VideoProvider>(
                builder: (context, provider, child) {
                  final isPlaying =
                      provider.currentPlayingVideo == widget.reply.identifier;

                  return Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isPlaying ? 0.0 : 0.8,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 32,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () => widget
                                .onTogglePlayback(widget.reply.identifier),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reply.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.reply.upvoteCount}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
