class Etablissement {
  String? code;
  String? name;
  String? rs;
  String? state;

  Etablissement({this.code, this.name, this.rs, this.state});

  factory Etablissement.fromJson(Map<String, dynamic> json) {
    return Etablissement(
      code: json['code'] ?? '',
      name: json['nom'] ?? '',
      rs: json['rs'] ?? '',
      state: json['etat'] ?? '',
    );
  }
}
