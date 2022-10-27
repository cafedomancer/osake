import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'add_sake_page.dart';
import 'sake_view_page.dart';

class SakeListPage extends StatefulWidget {
  const SakeListPage({super.key});

  @override
  State<SakeListPage> createState() => _SakeListPageState();
}

class _SakeListPageState extends State<SakeListPage> {
  void _onSakeView(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SakeViewPage(id: id),
      ),
    );
  }

  void _onAddSake() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSakePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ja_JP');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('osake'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('sakes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemBuilder: (context, index) {
              final sake = snapshot.data!.docs[index];

              final image = !sake.get('imageURL').isEmpty
                  ? Image.network(sake.get('imageURL'))
                  : const Icon(Icons.image);
              final brand = Text(sake.get('brand'));
              final title = !sake.get('title').isEmpty
                  ? Text(sake.get('title'))
                  : const Text('(No title)');
              final createdAt = Text(
                DateFormat.yMd('ja_JP').format(sake.get('createdAt').toDate()),
              );

              return ListTile(
                leading: image,
                title: brand,
                subtitle: title,
                trailing: createdAt,
                onTap: () => _onSakeView(sake.id),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddSake,
        child: const Icon(Icons.add),
      ),
    );
  }
}
