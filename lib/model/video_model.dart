class VideoPost {
  final int id;
  final String title;
  final String identifier;
  final int commentCount;
  final int upvoteCount;
  final int viewCount;
  final int shareCount;
  final String videoLink;
  final String thumbnailUrl;
  final String firstName;
  final String lastName;
  final String username;
  final String pictureUrl;
  final int childVideoCount;
  final bool upvoted;
  final bool bookmarked;
  final bool following;
  final DateTime createdAt;
  final Category? category;

  VideoPost({
    required this.id,
    required this.title,
    required this.identifier,
    required this.commentCount,
    required this.upvoteCount,
    required this.viewCount,
    required this.shareCount,
    required this.videoLink,
    required this.thumbnailUrl,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureUrl,
    required this.childVideoCount,
    required this.upvoted,
    required this.bookmarked,
    required this.following,
    required this.createdAt,
    this.category,
  });

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    return VideoPost(
      id: json['id'],
      title: json['title'],
      identifier: json['identifier'],
      commentCount: json['comment_count'],
      upvoteCount: json['upvote_count'],
      viewCount: json['view_count'],
      shareCount: json['share_count'],
      videoLink: json['video_link'],
      thumbnailUrl: json['thumbnail_url'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      pictureUrl: json['picture_url'],
      childVideoCount: json['child_video_count'],
      upvoted: json['upvoted'],
      bookmarked: json['bookmarked'],
      following: json['following'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      category: json['category'] != null && json['category'] is Map
          ? Category.fromJson(json['category'])
          : null,
    );
  }
}

class Category {
  final int id;
  final String name;
  final int count;
  final String description;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.count,
    required this.description,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}

class ApiResponse {
  final int page;
  final int maxPageSize;
  final int pageSize;
  final List<VideoPost> posts;

  ApiResponse({
    required this.page,
    required this.maxPageSize,
    required this.pageSize,
    required this.posts,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      page: json['page'],
      maxPageSize: json['max_page_size'],
      pageSize: json['page_size'],
      posts: (json['posts'] as List)
          .map((post) => VideoPost.fromJson(post))
          .toList(),
    );
  }
}