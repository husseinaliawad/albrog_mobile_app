import 'dart:convert';
import 'package:http/http.dart' as http;

class Activity {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String time;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activity_id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class ActivityService {
  static const String _baseUrl = 'https://albrog.com/get_user_activities.php';

  Future<List<Activity>> fetchActivities(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl?user_id=$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final List<dynamic> data = decoded['data'];
        return data.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception('API Error: ${decoded['message']}');
      }
    } else {
      throw Exception('Failed to load activities');
    }
  }
}
