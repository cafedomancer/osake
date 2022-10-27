import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'edit_sake_page.dart';

class SakeViewPage extends StatefulWidget {
  const SakeViewPage({super.key, required this.id});

  final String id;

  @override
  State<SakeViewPage> createState() => _SakeViewPageState();
}

class _SakeViewPageState extends State<SakeViewPage> {
  void _onEditSake(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSakePage(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ja_JP');

    return Scaffold(
      appBar: AppBar(
        title: const Text('osake'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('sakes')
              .doc(widget.id)
              .snapshots(),
          builder: (context, snapshot) {
            final sake = snapshot.data!;

            final image = !sake.get('imageURL').isEmpty
                ? Image.network(sake.get('imageURL'))
                : const Icon(Icons.image);
            final brand = Text(sake.get('brand'));
            final title = !sake.get('title').isEmpty
                ? Text(sake.get('title'))
                : const Text('(No title)');
            final createdAt = Text(
              DateFormat.yMd('ja_JP').format(
                sake.get('createdAt').toDate(),
              ),
            );

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: <Widget>[
                  image,
                  brand,
                  title,
                  createdAt,
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onEditSake(widget.id),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
