class FeedingModel {
  final int day;
  final bool food;
  final bool water;

  FeedingModel({
    required this.day,
    this.food = false,
    this.water = false,
  });

  factory FeedingModel.fromJson(Map<String, dynamic> json) {
    return FeedingModel(
      day: json['day'] as int,
      food: json['food'] as bool,
      water: json['water'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'food': food,
      'water': water,
    };
  }

  FeedingModel copyWith({
    int? day,
    bool? food,
    bool? water,
  }) {
    return FeedingModel(
      day: day ?? this.day,
      food: food ?? this.food,
      water: water ?? this.water,
    );
  }
}
