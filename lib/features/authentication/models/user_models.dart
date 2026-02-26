import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing user data.
class UserModel {
  final String id;
  String name;
  int age;
  String gender;
  String bio;
  final String email;
  String profilePicture;
  bool isOnline;

  List<String> likedUsers;
  List<String> likedByUsers;
  List<String> matches;
  List<String>? hobbies;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    required this.email,
    required this.profilePicture,
    required this.isOnline,
    required this.likedUsers,
    required this.likedByUsers,
    required this.matches,
    this.hobbies,
  });

  static UserModel empty() => UserModel(
    id: '',
    name: '',
    age: 18,
    gender: '',
    bio: '',
    email: '',
    profilePicture: '',
    isOnline: false,
    likedUsers: [],
    likedByUsers: [],
    matches: [],
    hobbies: [],
  );

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Age': age,
      'Gender': gender,
      'Bio': bio,
      'Email': email,
      'ProfilePicture': profilePicture,
      'IsOnline': isOnline,
      'LikedUsers': likedUsers,
      'LikedByUsers': likedByUsers,
      'Matches': matches,
      'Hobbies': hobbies ?? [],
    };
  }

  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) return UserModel.empty();

    final data = document.data()!;

    return UserModel(
      id: document.id,
      name: data['Name'] ?? '',
      age: data['Age'] ?? 18,
      gender: data['Gender'] ?? '',
      bio: data['Bio'] ?? '',
      email: data['Email'] ?? '',
      profilePicture: data['ProfilePicture'] ?? '',
      isOnline: data['IsOnline'] ?? false,
      likedUsers: List<String>.from(data['LikedUsers'] ?? []),
      likedByUsers: List<String>.from(data['LikedByUsers'] ?? []),
      matches: List<String>.from(data['Matches'] ?? []),
      hobbies: data['Hobbies'] != null
          ? List<String>.from(data['Hobbies']) : [],
    );
  }
}
