class People {
  final int? id;
  final String name;
  final String relationship;
  final String? description;
  final DateTime? createdAt;

  People({
    this.id,
    required this.name,
    required this.relationship,
    this.description,
    this.createdAt,
  });

  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      id: json['id'],
      name: json['name'],
      relationship: json['relationship'],
      description: json['description'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
