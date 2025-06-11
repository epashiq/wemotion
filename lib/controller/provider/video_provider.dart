import 'package:flutter/material.dart';
import 'package:fourd_scrolling_video_to_vide_app/controller/services/video_services.dart';
import 'package:fourd_scrolling_video_to_vide_app/model/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoProvider extends ChangeNotifier {
  List<VideoPost> _posts = [];
  Map<int, List<VideoPost>> _replies = {};
  Set<int> _expandedPosts = {};
  Map<int, bool> _loadingReplies = {};
  Map<String, VideoPlayerController> _videoControllers = {};
  String? _currentPlayingVideo;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

  List<VideoPost> get posts => _posts;
  Map<int, List<VideoPost>> get replies => _replies;
  Set<int> get expandedPosts => _expandedPosts;
  Map<int, bool> get loadingReplies => _loadingReplies;
  Map<String, VideoPlayerController> get videoControllers => _videoControllers;
  String? get currentPlayingVideo => _currentPlayingVideo;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;

  Future<void> initializeVideoPlayer(String videoUrl, String videoId) async {
    if (_videoControllers.containsKey(videoId)) return;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      _videoControllers[videoId] = controller;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void playVideo(String videoId) {
    if (_currentPlayingVideo != null && _currentPlayingVideo != videoId) {
      _videoControllers[_currentPlayingVideo!]?.pause();
    }

    _currentPlayingVideo = videoId;
    _videoControllers[videoId]?.play();
    notifyListeners();
  }

  void pauseVideo(String videoId) {
    _videoControllers[videoId]?.pause();
    if (_currentPlayingVideo == videoId) {
      _currentPlayingVideo = null;
    }
    notifyListeners();
  }

  void toggleVideoPlayback(String videoId) {
    final controller = _videoControllers[videoId];
    if (controller == null) return;

    if (controller.value.isPlaying) {
      pauseVideo(videoId);
    } else {
      playVideo(videoId);
    }
  }

  

  void onVideoVisibilityChanged(String videoId, bool isVisible) {
    if (isVisible) {
      autoplayVisibleVideo(videoId);
    } else {
      if (_currentPlayingVideo == videoId) {
        pauseVideo(videoId);
      }
    }
  }

  void disposeVideoController(String videoId) {
    _videoControllers[videoId]?.dispose();
    _videoControllers.remove(videoId);
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  Future<void> loadFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchFeed(page: 1);
      _posts = response.posts;
      _currentPage = 1;
      _hasMorePages = response.posts.length == response.pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchFeed(page: _currentPage + 1);
      _posts.addAll(response.posts);
      _currentPage++;
      _hasMorePages = response.posts.length == response.pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> togglePostExpansion(int postId) async {
    if (_expandedPosts.contains(postId)) {
      _expandedPosts.remove(postId);
    } else {
      _expandedPosts.add(postId);
      if (!_replies.containsKey(postId)) {
        await loadReplies(postId);
      }
    }
    notifyListeners();
  }

  Future<void> loadReplies(int postId) async {
    if (_loadingReplies[postId] == true) return;

    _loadingReplies[postId] = true;
    notifyListeners();

    try {
      final postReplies = await ApiService.fetchReplies(postId);
      _replies[postId] = postReplies;

      for (var reply in postReplies.take(2)) {
        await initializeVideoPlayer(reply.videoLink, reply.identifier);
      }
    } catch (e) {
      _replies[postId] = [];
      debugPrint('Error loading replies: $e');
    } finally {
      _loadingReplies[postId] = false;
      notifyListeners();
    }
  }

  Future<void> refreshFeed() async {
    _posts.clear();
    _replies.clear();
    _expandedPosts.clear();
    _currentPage = 1;
    _hasMorePages = true;
    await loadFeed();
  }

  void autoplayVisibleVideo(String videoId) {
    if (_currentPlayingVideo != videoId) {
      if (_currentPlayingVideo != null) {
        _videoControllers[_currentPlayingVideo!]?.pause();
      }

      _currentPlayingVideo = videoId;
      _videoControllers[videoId]?.play();
      notifyListeners();
    }
  }
}
