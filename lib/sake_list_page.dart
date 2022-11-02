import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_sake_page.dart';
import 'sake_view_page.dart';

class SakeListPage extends StatefulWidget {
  const SakeListPage({super.key});

  @override
  State<SakeListPage> createState() => _SakeListPageState();
}

class _SakeListPageState extends State<SakeListPage> {
  void _onSakeView(sake) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SakeViewPage(sake: sake),
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
            .orderBy('updatedAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final sake = snapshot.data!.docs[index];

                final image = sake.get('imageURL').isNotEmpty
                    ? Image.network(sake.get('imageURL'))
                    : const Icon(Icons.image); // TODO
                final brand = Text(sake.get('brand'));
                final title = sake.get('title').isNotEmpty
                    ? Text(sake.get('title'))
                    : const Text('(No title)');
                final createdAt = Text(
                  DateFormat('yyyy-MM-dd')
                      .format(sake.get('createdAt').toDate()),
                );

                return ListTile(
                  leading: image,
                  title: brand,
                  subtitle: title,
                  trailing: createdAt,
                  onTap: () => _onSakeView(sake),
                );
              },
              itemCount: snapshot.data!.docs.length,
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddSake,
        child: const Icon(Icons.add),
      ),
    );
  }
}
