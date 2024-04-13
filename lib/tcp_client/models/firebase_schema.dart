
class ChatLogs {

  final String userId;
  final Map coordinates;

  ChatLogs({
    required this.userId,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() =>
      {
        'userId': userId,
        'coordinates': coordinates,
      };

}