import 'dart:io';

import 'package:agenda/helpers/contact_helper.dart';
import 'package:agenda/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum orderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    // Contact c = Contact();
    // c.name = "josé";
    // c.email = "josésilva@gmail.com";
    // c.phone = "82855455";
    // c.img = "HTTP";
    // helper.saveContact(c);

    _listAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<orderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<orderOptions>>[
              const PopupMenuItem<orderOptions>(
                value: orderOptions.orderaz,
                child: Text("Ordenar de A-Z"),
              ),
              const PopupMenuItem<orderOptions>(
                value: orderOptions.orderza,
                child: Text("Ordenar de Z-A"),
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
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contacts[index].img != null
                              ? FileImage(File(contacts[index].img as String))
                              : AssetImage("images/person.png")
                                  as ImageProvider,
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacts[index].name ?? '',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contacts[index].email ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        contacts[index].phone ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onTap: () => _showOptions(context, index));
  }

  _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () {
                            launchUrlString("tel: ${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                          child: Text("Ligar",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                          child: Text("Editar",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () {
                            helper.deleteContact(contacts[index].id);
                            setState(() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                          child: Text("Excluir",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _listAllContacts();
    }
  }

  void _listAllContacts() {
    helper.listAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(orderOptions result) {
    switch (result) {
      case orderOptions.orderaz:
        contacts.sort(
          (a, b) {
            return a.name?.toLowerCase().compareTo(b.name!.toLowerCase()) ?? 0;
          },
        );
        break;
      case orderOptions.orderza:
        contacts.sort(
          (a, b) {
            return b.name?.toLowerCase().compareTo(a.name!.toLowerCase()) ?? 0;
          },
        );
        break;
    }
    setState(() {});
  }
}
