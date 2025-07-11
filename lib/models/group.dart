class Group {
  final String id;
  final String name;
  final List<String> memberIds;

  Group({required this.id, required this.name, required this.memberIds});

  Map<String, dynamic> toMap() {
    return {'name': name, 'memberIds': memberIds};
  }

  static Group fromMap(String id, Map<String, dynamic> map) {
    return Group(
      id: id,
      name: map['name'],
      memberIds: List<String>.from(map['memberIds']),
    );
  }
}
