// The type of avatar a child can choose
enum AvatarType { princess, unicorn, superhero, robot }

// The age group determines which exercise type the child gets
enum AgeGroup {
  early, // 3-4 years: hear & pick letter
  middle, // 4-7 years: hear word, build it
  advanced, // 7-16 years: hear sentence, type it
}

AgeGroup ageGroupFromAge(int age) {
  if (age <= 4) return AgeGroup.early;
  if (age <= 7) return AgeGroup.middle;
  return AgeGroup.advanced;
}

// Supported languages
enum AppLanguage { swedish, english }

/// Represents one child's profile in the app.
/// Each field is stored locally in Hive and synced to Firebase.
class UserProfile {
  final String id; // unique ID (matches Firebase doc ID)
  final String name;
  final int age;
  final AvatarType avatarType;
  final AppLanguage language;
  final String? passcode; // null = no passcode required
  final int points; // currency for the shop
  final int stars; // milestone badges
  final List<String> ownedAccessories; // IDs of bought accessories
  final String? equippedHat;
  final String? equippedCape;
  final String? equippedExtra;
  final DateTime createdAt;
  final DateTime lastPlayedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarType,
    required this.language,
    this.passcode,
    this.points = 0,
    this.stars = 0,
    this.ownedAccessories = const [],
    this.equippedHat,
    this.equippedCape,
    this.equippedExtra,
    required this.createdAt,
    required this.lastPlayedAt,
  });

  // What age group this profile belongs to
  AgeGroup get ageGroup => ageGroupFromAge(age);

  // Create a copy with some fields changed (useful when updating score)
  UserProfile copyWith({
    String? name,
    int? age,
    AvatarType? avatarType,
    AppLanguage? language,
    String? passcode,
    bool clearPasscode = false,
    int? points,
    int? stars,
    List<String>? ownedAccessories,
    String? equippedHat,
    String? equippedCape,
    String? equippedExtra,
    DateTime? lastPlayedAt,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarType: avatarType ?? this.avatarType,
      language: language ?? this.language,
      passcode: clearPasscode ? null : (passcode ?? this.passcode),
      points: points ?? this.points,
      stars: stars ?? this.stars,
      ownedAccessories: ownedAccessories ?? this.ownedAccessories,
      equippedHat: equippedHat ?? this.equippedHat,
      equippedCape: equippedCape ?? this.equippedCape,
      equippedExtra: equippedExtra ?? this.equippedExtra,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  // Convert to a Map so we can save it to Firebase or Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'avatarType': avatarType.name,
      'language': language.name,
      'passcode': passcode,
      'points': points,
      'stars': stars,
      'ownedAccessories': ownedAccessories,
      'equippedHat': equippedHat,
      'equippedCape': equippedCape,
      'equippedExtra': equippedExtra,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
    };
  }

  // Create a UserProfile from a saved Map (loading from storage)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      avatarType: AvatarType.values.firstWhere(
        (e) => e.name == map['avatarType'],
        orElse: () => AvatarType.robot,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.name == map['language'],
        orElse: () => AppLanguage.swedish,
      ),
      passcode: map['passcode'] as String?,
      points: map['points'] as int? ?? 0,
      stars: map['stars'] as int? ?? 0,
      ownedAccessories: List<String>.from(map['ownedAccessories'] ?? []),
      equippedHat: map['equippedHat'] as String?,
      equippedCape: map['equippedCape'] as String?,
      equippedExtra: map['equippedExtra'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastPlayedAt: DateTime.parse(map['lastPlayedAt'] as String),
    );
  }
}
