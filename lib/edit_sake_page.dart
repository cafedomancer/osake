import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:osake/sake_list_page.dart';

class EditSakePage extends StatefulWidget {
  const EditSakePage({super.key, required this.id});

  final String id;

  @override
  State<EditSakePage> createState() => _EditSakePageState();
}

class _EditSakePageState extends State<EditSakePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _titleController = TextEditingController();
  File? _image;

  _onEditImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) return;
    setState(() {
      _image = File(result.files.single.path!);
    });
  }

  _onEditSake() async {
    if (!_formKey.currentState!.validate()) return;
    final brand = _brandController.text;
    final title = _titleController.text;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('sakes')
        .doc(widget.id)
        .update(<String, dynamic>{
      'brand': brand,
      'title': title,
      'updatedAt': Timestamp.now(),
    });

    if (_image != null) {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('sakes')
          .child(widget.id)
          .child('image');
      await imageRef.putFile(_image!);
      final imageURL = await imageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('sakes')
          .doc(widget.id)
          .update(<String, String>{
        'imageURL': imageURL,
      });
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  _onDeleteSake() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              final sake = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('sakes')
                  .doc(widget.id)
                  .get();

              if (!sake.get('imageURL').isEmpty) {
                await FirebaseStorage.instance
                    .ref()
                    .child('users')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .child('sakes')
                    .child(widget.id)
                    .child('image')
                    .delete();
              }

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('sakes')
                  .doc(widget.id)
                  .delete();

              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SakeListPage(),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deleteSakeButton = IconButton(
      icon: const Icon(Icons.delete),
      tooltip: 'Show Snackbar',
      onPressed: _onDeleteSake,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('osake'),
        actions: <Widget>[
          deleteSakeButton,
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('sakes')
            .doc(widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          final sake = snapshot.data!;

          _brandController.text = sake.get('brand');
          _titleController.text = sake.get('title');

          final imageField = _image != null
              ? Image.file(_image!)
              : !sake.get('imageURL').isEmpty
                  ? Image.network(sake.get('imageURL'))
                  : IconButton(
                      onPressed: _onEditImage,
                      icon: const Icon(Icons.image),
                    );
          final brandField = TextFormField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: 'Brand *'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          );
          final titleField = TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          );
          final editSakeButton = ElevatedButton(
            onPressed: _onEditSake,
            child: const Text('Edit sake'),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Center(
                child: ListView(
                  children: <Widget>[
                    imageField,
                    brandField,
                    titleField,
                    editSakeButton,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
