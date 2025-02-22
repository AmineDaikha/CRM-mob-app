class SFamilly {
  String code;
  String name;
  String type;

  SFamilly({
    required this.code,
    required this.name,
    required this.type,
  });

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //         other is SFamilly &&
  //             runtimeType == other.runtimeType &&
  //             code == other.code &&
  //             name == other.name &&
  //             type == other.type;
  //
  // @override
  // int get hashCode => code.hashCode ^ name.hashCode ^ type.hashCode;
}
