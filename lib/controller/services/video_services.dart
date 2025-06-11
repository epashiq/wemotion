import 'dart:convert';
import 'package:fourd_scrolling_video_to_vide_app/model/video_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.wemotions.app';

  static Future<ApiResponse> fetchFeed({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feed?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  
  static Future<List<VideoPost>> fetchReplies(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/replies'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey('post')) {
          final replies = jsonData['post'] as List<dynamic>;
          return replies.map((reply) => VideoPost.fromJson(reply)).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load replies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
