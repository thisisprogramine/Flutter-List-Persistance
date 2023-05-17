class Model{
  //final String id;
  final String name;
  final String picture;
  final String age;
  final String country;

  const Model({
    //required this.id,
    required this.name,
    required this.picture,
    required this.age,
    required this.country,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
        //id: json['id'],
        name: json['name']['title'] + " " + json['name']['first'] + " " +  json['name']['last'],
        picture: json['picture']['large'],
        age: json['dob']['age'].toString(),
        country: json['location']['country'],
    );
  }

}
