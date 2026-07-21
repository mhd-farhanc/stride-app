/// Model representing an achievement badge.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: '', // filled from static list
      description: '',
      icon: '',
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }
}
