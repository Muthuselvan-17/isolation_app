class FeedingModel {
  final int day;
  final bool food;
  final bool water;
  final String status;

  FeedingModel({
    required this.day,
    this.food = false,
    this.water = false,
    this.status = 'Normal',
  });

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final s = value.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'y';
    }
    return false;
  }

  factory FeedingModel.fromJson(Map<String, dynamic> json) {
    final foodVal = _parseBool(json['food']);
    final waterVal = _parseBool(json['water']);
    return FeedingModel(
      day: json['day'] as int,
      food: foodVal,
      water: waterVal,
      status: json['status'] as String? ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'food': food,
      'water': water,
      'status': status,
    };
  }

  FeedingModel copyWith({
    int? day,
    bool? food,
    bool? water,
    String? status,
  }) {
    return FeedingModel(
      day: day ?? this.day,
      food: food ?? this.food,
      water: water ?? this.water,
      status: status ?? this.status,
    );
  }
}
