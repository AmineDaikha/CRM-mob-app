import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/etablissement.dart';

class EtablissPage extends StatelessWidget {
  const EtablissPage({super.key, required this.etablissementsList});
  final List<Etablissement> etablissementsList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 80,
          padding: EdgeInsets.all(10),
          child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(12),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) => EtablissItem(
                    etablissement: etablissementsList.toList()[index],
                  ),
              itemCount: etablissementsList.length),
        ),
      ),
    );
  }
}

class EtablissItem extends StatelessWidget {
  const EtablissItem({super.key, required this.etablissement});

  final Etablissement etablissement;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {

      },
      leading: Text(
        etablissement.code!,
        style: Theme.of(context).textTheme.headline4,
      ),
      title: Center(
        child: Text(etablissement.name!,
            style: Theme.of(context).textTheme.headline5!.copyWith(fontWeight: FontWeight.normal)),
      ),
    );
  }
}
