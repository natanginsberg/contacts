import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRecord {
  CollectionReference contactDoc =
      FirebaseFirestore.instance.collection('contact');

  Future<Map<String, dynamic>> getRecord() async {
    DocumentSnapshot record = await contactDoc.doc("record").get();
    print(record.id);
    return record.data() as Map<String, dynamic>;
  }
}
