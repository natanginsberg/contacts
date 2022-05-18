import 'package:contacts/pdf_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_record.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage(this.contact);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

enum categories {
  phone,
  email,
  website,
  socialMedia,
  address,
  organization,
  group
}

List<String> monthsOfTheYear = [
  'January',
  'February',
  'March',
  'April',
  'May',
  "June",
  "July",
  'August',
  'September',
  'October',
  'November',
  'December'
];

class _ContactPageState extends State<ContactPage> {
  String ADDRESS_ERROR = "Unable to open address";
  String EMAIL_ERROR = "Unable to send email to ";
  String PHONE_ERROR = "Unable to place phone call to ";
  String DATE_ERROR = "Unable to open calendar";
  String WEBSITE_ERROR = "Unable to open ";
  String FILE_ERROR = "Unable to open file";

  Map<String, dynamic> firebaseRecord = {};

  var pressed = false;

  getFirebaseRecords() async {
    firebaseRecord = await FirebaseRecord().getRecord();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFirebaseRecords();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xF8F8F8FC),
      appBar: AppBar(
          title: Text(
              '${widget.contact.name.prefix} ${widget.contact.name.first} ${widget.contact.name.middle} ${widget.contact.name.last} ${widget.contact.name.suffix}')),
      body: ListView(children: [
        if (widget.contact.photo != null || widget.contact.thumbnail != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: Image.memory(widget.contact.photoOrThumbnail!)),
          ),
        if (widget.contact.phones.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.phones.length, categories.phone),
        if (widget.contact.emails.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.emails.length, categories.email),
        if (widget.contact.socialMedias.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.socialMedias.length, categories.socialMedia),
        if (widget.contact.addresses.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.addresses.length, categories.address),
        if (widget.contact.organizations.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.organizations.length, categories.organization),
        if (widget.contact.websites.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.websites.length, categories.website),
        if (widget.contact.groups.isNotEmpty)
          genericListOfContactInfo(
              widget.contact.groups.length, categories.group),
        if (widget.contact.events.isNotEmpty) events(),
        if (widget.contact.notes.isNotEmpty) notes(),
        Padding(padding: const EdgeInsets.all(8.0), child: firebasePics()),
        Padding(padding: const EdgeInsets.all(8.0), child: firebaseDocs()),
        Padding(padding: const EdgeInsets.all(8.0), child: firebaseUrls()),
      ]));

  genericListOfContactInfo(int lengthOfList, categories category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const Divider(
                    color: Colors.black,
                  ),
              itemCount: lengthOfList,
              itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: detail(index, category))),
        ),
      ),
    );
  }

  detail(int index, categories category) {
    String title = "";
    String detail = "";
    var function;
    switch (category) {
      case categories.email:
        title = widget.contact.emails[index].label.name;
        detail = widget.contact.emails[index].address;
        function = () => sendEmail(widget.contact.emails[index].address);
        break;
      case categories.phone:
        title = widget.contact.phones[index].label.name;
        detail = widget.contact.phones[index].number;
        function = () => phoneCall(widget.contact.phones[index].number);
        break;
      case categories.socialMedia:
        title = widget.contact.socialMedias[index].label.name;
        detail = widget.contact.socialMedias[index].userName;
        break;
      case categories.address:
        title = widget.contact.addresses[index].label.name;
        detail = widget.contact.addresses[index].address;
        function = () => openAddress(widget.contact.addresses[index].address);
        break;
      case categories.website:
        title = widget.contact.websites[index].label.name;
        detail = widget.contact.websites[index].url;
        function = () => openWebsite(widget.contact.websites[index].url);
        break;
      case categories.organization:
        title = widget.contact.organizations[index].company;
        detail = widget.contact.organizations[index].title;
        break;
      case categories.group:
        title = widget.contact.groups[index].id;
        detail = widget.contact.groups[index].name;
        break;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
      const SizedBox(
        height: 8,
      ),
      function != null
          ? TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              onPressed: function,
              child: Text(
                detail,
                style: const TextStyle(fontSize: 16),
              ),
            )
          : Text(
              detail,
              style: const TextStyle(fontSize: 16),
            ),
    ]);
  }

  events() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: widget.contact.events.length,
            itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contact.events[index].label.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      widget.contact.events[index].year != null
                          ? TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              onPressed: () {
                                String date =
                                    '${widget.contact.events[index].day}'
                                    '-${widget.contact.events[index].month}'
                                    "-${widget.contact.events[index].year}";
                                DateFormat inputFormat =
                                    DateFormat('dd-MM-yyyy');
                                final formattedDate = inputFormat.parse(date);
                                DateTime? sdate =
                                    DateTime.parse(formattedDate.toString());
                                int difference = 0;
                                if (Platform.isAndroid) {
                                  launchCustomUrl(
                                      'content://com.android.calendar/time/${sdate.millisecondsSinceEpoch}',
                                      DATE_ERROR);
                                } else if (Platform.isIOS) {
                                  final intervalDate =
                                      inputFormat.parse("01-01-2001");
                                  difference = sdate
                                      .difference(DateTime.parse(
                                          intervalDate.toString()))
                                      .inSeconds;
                                  launchCustomUrl(
                                      'calshow:$difference', DATE_ERROR);
                                }
                              },
                              child: Text(
                                  '${monthsOfTheYear[widget.contact.events[index].month - 1]} '
                                  '${widget.contact.events[index].day} '
                                  ", ${widget.contact.events[index].year}",
                                  style: const TextStyle(fontSize: 16)))
                          : Text(
                              '${monthsOfTheYear[widget.contact.events[index].month - 1]} '
                              '${widget.contact.events[index].day}'),
                    ])),
          ),
        ),
      ),
    );
  }

  notes() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: widget.contact.notes.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.contact.notes[index].note),
            ),
          ),
        ),
      ),
    );
  }

  firebasePics() {
    if (firebaseRecord.isEmpty) {
      return const CupertinoActivityIndicator();
    } else {
      if (firebaseRecord.containsKey("pics")) {
        List<String> pics = List<String>.from(firebaseRecord["pics"]);
        return Container(
          height: MediaQuery.of(context).size.height / 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [
              const Text("Internet Pictures"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: pics.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () => openPicDialog(pics[index]),
                          child: Image.network(
                            pics[index],
                            scale: 1,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    }
  }

  firebaseDocs() {
    if (firebaseRecord.isEmpty) {
      return const CupertinoActivityIndicator();
    } else {
      if (firebaseRecord.containsKey("docAndValues")) {
        List<Map<String, dynamic>> docs =
            List<Map<String, dynamic>>.from(firebaseRecord["docAndValues"]);
        return Container(
          height: MediaQuery.of(context).size.height / 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [
              const Text("Documents From Internet"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => openPdfDialog(docs[index]["url"]),
                          child: Text(docs[index]["name"]),
                        )),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    }
  }

  firebaseUrls() {
    if (firebaseRecord.isEmpty) {
      return const CupertinoActivityIndicator();
    } else {
      if (firebaseRecord.containsKey("urls")) {
        List<String> urls = List<String>.from(firebaseRecord["urls"]);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black,
              ),
              itemCount: urls.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                    onPressed: () => launchCustomUrl(urls[index]),
                    child: Text(urls[index])),
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  launchCustomUrl(String url, [String errorText = ""]) async {
    if (!await launchUrl(Uri.parse(url))) {
      String text = WEBSITE_ERROR + url;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText.isEmpty ? text : errorText)));
    }
  }

  openPicDialog(String pic) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Image.network(pic));
        });
  }

  openPdfDialog(String doc) async {
    try {
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return PDF(doc);
          });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(FILE_ERROR)));
    }
  }

  sendEmail(String url) {
    launchCustomUrl('mailto:$url', EMAIL_ERROR + url);
  }

  phoneCall(String number) {
    launchCustomUrl('tel:$number', PHONE_ERROR + number);
  }

  openAddress(String address) {
    String query = Uri.encodeComponent(address);
    String googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    launchCustomUrl(googleUrl, ADDRESS_ERROR + address);
  }

  openWebsite(String url) {
    launchCustomUrl(url);
  }
}
