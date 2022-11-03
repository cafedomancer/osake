import 'dart:ffi';

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
  String _field = 'brand';
  bool _descending = false;

  void _onSortSake(field) {
    setState(() {
      _field = field;
      _descending = !_descending;
    });
  }

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
    final sortSakeButton = PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => _onSortSake('brand'),
          child: const Text('Brand'),
        ),
        PopupMenuItem(
          onTap: () => _onSortSake('createdAt'),
          child: const Text('Created at'),
        ),
        PopupMenuItem(
          onTap: () => _onSortSake('updatedAt'),
          child: const Text('Updated at'),
        ),
      ],
      icon: const Icon(Icons.sort),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('osake'),
        actions: <Widget>[
          sortSakeButton,
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('sakes')
            .orderBy(_field, descending: _descending)
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
