import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'edit_sake_page.dart';

class SakeViewPage extends StatefulWidget {
  const SakeViewPage({super.key, required this.sake});

  final sake;

  @override
  State<SakeViewPage> createState() => _SakeViewPageState();
}

class _SakeViewPageState extends State<SakeViewPage> {
  void _onEditSake(sake) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSakePage(sake: sake),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('osake'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('sakes')
              .doc(widget.sake.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              final sake = snapshot.data!;

              final image = sake.get('imageURL').isNotEmpty
                  ? Image.network(sake.get('imageURL'))
                  : const Icon(Icons.image); // TODO
              final brand = Text(sake.get('brand'));
              final title = sake.get('title').isNotEmpty
                  ? Text(sake.get('title'))
                  : const Text('(No title)');
              final createdAt = Text(
                DateFormat('yyyy-MM-dd HH:mm').format(
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
            } else {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onEditSake(widget.sake),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
