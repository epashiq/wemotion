import 'package:flutter/material.dart';
import 'package:fourd_scrolling_video_to_vide_app/controller/provider/video_provider.dart';
import 'package:fourd_scrolling_video_to_vide_app/model/video_model.dart';
import 'package:fourd_scrolling_video_to_vide_app/view/widgets/video_reply_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPostWidget extends StatefulWidget {
  final VideoPost post;
  final Function(String, String) onVideoInitialize;
  final Function(String) onTogglePlayback;
  final Function(String, bool) onVisibilityChanged;
  final VoidCallback onToggleExpansion;

  const VideoPostWidget({
    super.key,
    required this.post,
    required this.onVideoInitialize,
    required this.onTogglePlayback,
    required this.onVisibilityChanged,
    required this.onToggleExpansion,
  });

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideo();
  }

  void initializeVideo() async {
    if (!isInitialized) {
      await widget.onVideoInitialize(
        widget.post.videoLink,
        widget.post.identifier,
      );
      if (!mounted) return;
      setState(() {
        isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Column(
        children: [
          VisibilityDetector(
            key: Key('main_video_${widget.post.identifier}'),
            onVisibilityChanged: (info) {
              final isVisible = info.visibleFraction > 0.5;
              widget.onVisibilityChanged(widget.post.identifier, isVisible);
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: double.infinity,
              child: Stack(
                children: [
                  Consumer<VideoProvider>(
                    builder: (context, provider, child) {
                      final controller =
                          provider.videoControllers[widget.post.identifier];
                      if (controller == null ||
                          !controller.value.isInitialized) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      }

                      return InkWell(
                        onTap: () =>
                            widget.onTogglePlayback(widget.post.identifier),
                        child: AspectRatio(
                          aspectRatio: 0.7,
                          child: VideoPlayer(controller),
                        ),
                      );
                    },
                  ),
                  Consumer<VideoProvider>(
                    builder: (context, provider, child) {
                      final isPlaying = provider.currentPlayingVideo ==
                          widget.post.identifier;
                      return Positioned.fill(
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 64,
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () => widget
                                    .onTogglePlayback(widget.post.identifier),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.post.firstName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.favorite_border,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.post.upvoteCount}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.comment_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.post.commentCount}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
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
          Consumer<VideoProvider>(
            builder: (context, provider, child) {
              final isExpanded =
                  provider.expandedPosts.contains(widget.post.id);
              final replies = provider.replies[widget.post.id] ?? [];
              final isLoading =
                  provider.loadingReplies[widget.post.id] ?? false;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[900],
                    child: TextButton.icon(
                      onPressed: () async {
                        widget.onToggleExpansion();

                        if (!isExpanded && replies.isEmpty && !isLoading) {
                          await Provider.of<VideoProvider>(context,
                                  listen: false)
                              .loadReplies(widget.post.id);
                        }
                      },
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      label: Text(
                        isExpanded ? 'Hide Replies' : 'Show Replies',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      height: 200,
                      color: Colors.grey[900],
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : replies.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          color: Colors.grey, size: 48),
                                      SizedBox(height: 8),
                                      Text(
                                        'No replies yet',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount: replies.length,
                                  itemBuilder: (context, index) {
                                    final reply = replies[index];
                                    return ReplyVideoWidget(
                                      reply: reply,
                                      onVideoInitialize:
                                          widget.onVideoInitialize,
                                      onTogglePlayback: widget.onTogglePlayback,
                                      onVisibilityChanged:
                                          widget.onVisibilityChanged,
                                    );
                                  },
                                ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
