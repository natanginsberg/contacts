import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'contact_page.dart';
import 'firebase_options.dart';

void main() => runApp(const FlutterContactsExample());

class FlutterContactsExample extends StatefulWidget {
  const FlutterContactsExample({Key? key}) : super(key: key);

  @override
  _FlutterContactsExampleState createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  var controller = TextEditingController();

  List<Contact>? _allContacts;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    initiateFirebase();
  }

  initiateFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      _allContacts = contacts;
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text('Contacts')), body: _body()));

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        searchBar(),
        Expanded(
          child: ListView.builder(
              itemCount: _contacts!.length,
              itemBuilder: (context, i) => ListTile(
                  title: Text(_contacts![i].displayName),
                  onTap: () async {
                    final fullContact =
                        await FlutterContacts.getContact(_contacts![i].id);
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ContactPage(fullContact!)));
                  })),
        ),
      ],
    );
  }

  searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white70),
          child: ListTile(
            leading: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            title: TextField(
              style: const TextStyle(color: Colors.black),
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.black38),
                fillColor: Colors.transparent,
              ),
              onChanged: (String value) {
                if (_allContacts != null) {
                  _contacts = List.from(_allContacts!.where((element) => element
                      .displayName
                      .toLowerCase()
                      .toString()
                      .split(" ")
                      .where(
                          (element) => element.startsWith(value.toLowerCase()))
                      .isNotEmpty));
                  setState(() {});
                }
              },
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.cancel,
                color: Colors.black,
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  controller.clear();
                  _contacts = List.from(_allContacts!);
                  setState(() {});
                }
              },
            ),
          )),
    );
  }
}


