const String tableFeed = 'feed';

class FeedFields {
  static final List<String> values = [
    /// Add all fields
    id, name, picture, age, country
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String picture = 'picture';
  static const String age = 'age';
  static const String country = 'country';
}


class Feed{
  final int? id;
  final String name;
  final String picture;
  final String age;
  final String country;

  const Feed({
    this.id,
    required this.name,
    required this.picture,
    required this.age,
    required this.country,
  });

  Feed copy({
    int? id,
    String? name,
    String? picture,
    String? age,
    String? country,
  }) =>
      Feed(
        id: id ?? this.id,
        name: name ?? this.name,
        picture: picture ?? this.picture,
        age: age ?? this.age,
        country: country ?? this.country,
      );

  static Feed fromJson(Map<String, Object?> json) => Feed(
    id: json[FeedFields.id] as int?,
    name: json[FeedFields.name] as String,
    picture: json[FeedFields.picture] as String,
    age: json[FeedFields.age] as String,
    country: json[FeedFields.country] as String,
  );

  Map<String, Object?> toJson() => {
    FeedFields.id: id,
    FeedFields.name: name,
    FeedFields.picture: picture,
    FeedFields.age: age,
    FeedFields.country: country,
  };

}