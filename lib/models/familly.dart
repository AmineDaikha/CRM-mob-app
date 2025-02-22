class Familly {
  String code;
  String name;
  String type;

  Familly({required this.code, required this.name, required this.type});

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //         other is Familly &&
  //             runtimeType == other.runtimeType &&
  //             code == other.code &&
  //             name == other.name &&
  //             type == other.type;
  //
  // @override
  // int get hashCode => code.hashCode ^ name.hashCode ^ type.hashCode;
}
