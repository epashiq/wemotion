
import 'package:flutter/material.dart';
import 'package:fourd_scrolling_video_to_vide_app/controller/provider/video_provider.dart';
import 'package:fourd_scrolling_video_to_vide_app/view/widgets/error_display_widget.dart';
import 'package:fourd_scrolling_video_to_vide_app/view/widgets/video_post_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadFeed();
    });
    _scrollController.addListener(_onMainScroll);
  }

  void _onMainScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<VideoProvider>().loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.error != null && provider.posts.isEmpty) {
            return ErrorDisplayWidget(
              errorMessage: provider.error!,
              onRetry: provider.loadFeed,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshFeed,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const SliverAppBar(
                  backgroundColor: Colors.black,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    'Video Feed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /// List of video posts
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      }

                      final post = provider.posts[index];
                      return VideoPostWidget(
                        post: post,
                        onVideoInitialize: (videoUrl, videoId) {
                          provider.initializeVideoPlayer(videoUrl, videoId);
                        },
                        onTogglePlayback: provider.toggleVideoPlayback,
                        onVisibilityChanged:
                            provider.onVideoVisibilityChanged,
                        onToggleExpansion: () =>
                            provider.togglePostExpansion(post.id),
                      );
                    },
                    childCount: provider.posts.length +
                        (provider.isLoadingMore ? 1 : 0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

