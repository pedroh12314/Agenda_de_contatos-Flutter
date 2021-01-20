import 'package:Agenda_de_contatos/classes/contact_class.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactClass contactHelper = ContactClass();

  @override
  void initState() {
    super.initState();

    Contact c = Contact();
    c.name = "Pedro test";
    c.telefone = "32323";
    c.email = "wwwww@teste.com";
    c.img = "imagem";

    contactHelper.saveContact(c);

    contactHelper.getAllContact().then((value) {
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
