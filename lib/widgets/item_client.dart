import 'package:flutter/material.dart';

class clientItem extends StatelessWidget {
  const clientItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 30),
            height: 400,
            child: ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text(
                'Client 1',
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              subtitle: Text(
                'Client 1',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.call_outlined,
                        color: Colors.grey,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.mail_outline,
                        color: Colors.grey,
                      ))
                ],
              ),
            ),
          )),
    );
  }
}
