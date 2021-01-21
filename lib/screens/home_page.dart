import 'dart:io';

import 'package:Agenda_de_contatos/classes/contact_class.dart';
import 'package:Agenda_de_contatos/screens/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactClass contactHelper = ContactClass();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (contex) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A - Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z - A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].telefone ?? "",
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptons(context, index);
      },
      onLongPress: () {
        _showShare(contacts[index]);
      },
      onDoubleTap: () {
        _showContactPage(contato: contacts[index]);
      },
    );
  }

  void _showShare(Contact contato) {
    Share.share(contato.toString());
  }

  void _showContactPage({Contact contato}) async {
    final contactBack = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contato,
                )));

    if (contactBack != null) {
      if (contato != null) {
        await contactHelper.updateContact(contactBack);
      } else {
        await contactHelper.saveContact(contactBack);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    contactHelper.getAllContact().then((value) {
      setState(() {
        contacts = value;
      });
    });
  }

  _showOptons(BuildContext contex, int index) {
    showModalBottomSheet(
        context: contex,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (contex) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: () {
                            launch("tel::${contacts[index].telefone}");
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contato: contacts[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: () {
                            _showConfirmDelete(context, index);
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          )),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  Future<bool> _showConfirmDelete(BuildContext contex, int index) {
    showDialog(
        context: context,
        builder: (contex) {
          return AlertDialog(
            title: Text("Excluir Contato?"),
            content: Text(
                "Esta ação exclui permanentemente o contato \"${contacts[index].name}\"."),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    contactHelper.deleteContact(contacts[index].id);
                    setState(() {
                      contacts.removeAt(index);
                    });
                  },
                  child: Text(
                    "Excluir",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
    return Future.value(false);
  }
}
