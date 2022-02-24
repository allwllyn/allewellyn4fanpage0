class User {
  final String id;
  final String displayName;
  final String role;

  User({required this.id, required this.displayName, required this.role});

  User.fromJson(String id, Map<String, dynamic> json)
      : this(id: id, displayName: json["display_name"], role: json["role"]);

  Map<String, Object?> toJson() {
    return {"display_name": displayName, "role": role};
  }

  bool isAdmin() {
    return this.role == "ADMIN";
  }
}
