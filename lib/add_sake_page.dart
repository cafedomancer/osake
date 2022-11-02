import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exif/exif.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  final _createdAtController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _titleController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  _onAddImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024.0,
      maxHeight: 1024.0,
    );
    if (file == null) return;
    setState(() {
      _image = File(file.path);
    });

    final data = await readExifFromBytes(_image!.readAsBytesSync());
    setState(() {
      print(data);
      _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(
        DateFormat('yyyy:MM:dd HH:mm:ss')
            .parse(data['Image DateTime'].toString()),
      );
    });
  }

  _onAddSake() async {
    if (!_formKey.currentState!.validate()) return;
    final brand = _brandController.text;
    final title = _titleController.text;
    final imageURL = '';
    final createdAt = _createdAtController.text.isNotEmpty
        ? Timestamp.fromDate(DateTime.parse(_createdAtController.text))
        : Timestamp.now();
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
        ? GestureDetector(
            child: Image.file(_image!),
            onTap: _onAddImage,
          )
        : IconButton(
            onPressed: _onAddImage,
            icon: const Icon(Icons.image),
          );
    final brandField = TextFormField(
      controller: _brandController,
      decoration: const InputDecoration(
        labelText: 'Brand *',
        hintText: '十四代',
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter some text' : null,
    );
    final titleField = TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: '本丸 秘伝玉返し',
      ),
    );
    final createdAtField = TextFormField(
      controller: _createdAtController,
      decoration: const InputDecoration(
        labelText: 'Created at',
        hintText: 'YYYY-MM-DD HH:MM',
      ),
      keyboardType: TextInputType.datetime,
    );
    final addSakeButton = ElevatedButton(
      onPressed: () => _onAddSake(),
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
              createdAtField,
              addSakeButton,
            ],
          ),
        ),
      ),
    );
  }
}
