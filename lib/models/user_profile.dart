class UserProfile {
  final String? uid;
  String? name;
  String? email;
  String? photoURL;
  int followers;
  int following;
  int ranking;
  String? bio;

  UserProfile(this.followers, this.following, this.ranking, this.bio,
      {this.uid, this.name, this.email, this.photoURL});

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(map['followers'], map['following'], map['ranking'], map['bio'],
        uid: map['uid'],
        name: map['name'],
        email: map['email'],
        photoURL: map['photoURL']);
  }

  void updatePhotoURL(String photoURL) {
    this.photoURL = photoURL;

  }

  void updateName(String name) {
    this.name = name;
  }

  void updateBio(String bio) {
    this.bio = bio;
  }

  void updateEmail(String email) {
    this.email = email;
  }
}
