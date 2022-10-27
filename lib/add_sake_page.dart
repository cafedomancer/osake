import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddSakePage extends StatefulWidget {
  const AddSakePage({super.key});

  @override
  State<AddSakePage> createState() => _AddSakePageState();
}

class _AddSakePageState extends State<AddSakePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _titleController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _brandController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  _onAddImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) return;
    setState(() {
      _image = File(result.files.single.path!);
    });
  }

  _onAddSake() async {
    if (!_formKey.currentState!.validate()) return;
    final brand = _brandController.text;
    final title = _titleController.text;
    final imageURL = '';
    final createdAt = Timestamp.now();
    final updatedAt = Timestamp.now();
    final sake = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('sakes')
        .add(<String, dynamic>{
      'brand': brand,
      'title': title,
      'imageURL': imageURL,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    });

    if (_image != null) {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('sakes')
          .child(sake.id)
          .child('image');
      await imageRef.putFile(_image!);
      final imageURL = await imageRef.getDownloadURL();
      await sake.update(<String, String>{
        'imageURL': imageURL,
      });
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageField = _image != null
        ? Image.file(_image!)
        : IconButton(
            onPressed: _onAddImage,
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
    final addButton = ElevatedButton(
      onPressed: () {
        _onAddSake();
      },
      child: const Text('Add sake'),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('osake'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              imageField,
              brandField,
              titleField,
              addButton,
            ],
          ),
        ),
      ),
    );
  }
}
