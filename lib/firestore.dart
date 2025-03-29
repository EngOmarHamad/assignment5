import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _ItemsCollection = FirebaseFirestore.instance
      .collection('items');
  Future<void> addItem(String uid, String title, String description) {
    return _ItemsCollection.add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': uid,
    });
  }

  Future<void> updateItem(String uid, String title, String description) {
    return _ItemsCollection.doc(
      uid,
    ).update({'title': title, 'description': description});
  }

  Future<void> deleteItem(String uid) {
    return _ItemsCollection.doc(uid).delete();
  }

  Future<DocumentSnapshot> getItem(String uid) {
    return _ItemsCollection.doc(uid).get();
  }

  Stream<QuerySnapshot> getItemsStream() {
    return _ItemsCollection.orderBy('createdAt', descending: true).snapshots();
  }
}
