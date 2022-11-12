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
  String? _brand = '';
  String? _title = '';
  File? _image;
  String? _createdAt = '';

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
      _createdAt = DateFormat('yyyy-MM-dd HH:mm').format(
        DateFormat('yyyy:MM:dd HH:mm:ss')
            .parse(data['Image DateTime'].toString()),
      );
    });
  }

  _onAddSake() async {
    if (!_formKey.currentState!.validate()) return;
    final brand = _brand;
    final title = _title;
    final imageURL = '';
    final createdAt = _createdAt!.isNotEmpty
        ? Timestamp.fromDate(DateTime.parse(_createdAt!))
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
      initialValue: _brand,
      decoration: const InputDecoration(
        labelText: 'Brand *',
        hintText: '十四代',
      ),
      onChanged: (value) {
        setState(() {
          _brand = value;
        });
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter some text' : null,
    );
    final titleField = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: '本丸 秘伝玉返し',
      ),
      onChanged: (value) {
        setState(() {
          _title = value;
        });
      },
    );
    final createdAtField = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Created at',
        hintText: 'YYYY-MM-DD HH:MM',
      ),
      keyboardType: TextInputType.datetime,
      onChanged: (value) {
        setState(() {
          _createdAt = value;
        });
      },
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
              StreamBuilder(
                stream: _brand!.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('sakes')
                        .orderBy(RegExp(r'^[0-9A-Za-z]+$').hasMatch(_brand!)
                            ? 'brandRomaji'
                            : RegExp(r'^[あ-ん]+$').hasMatch(_brand!)
                                ? 'brandKana'
                                : 'brand')
                        .startAt([_brand])
                        .endAt(['$_brand\uf8ff'])
                        .limit(10)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('sakes')
                        .orderBy('createdAt')
                        .limit(10)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Wrap(
                      children: snapshot.data!.docs
                          .map(
                            (sake) => ActionChip(
                              label: Text(sake.get('brand')),
                              onPressed: () {
                                setState(() {
                                  _brand = sake.get('brand');
                                });
                              },
                            ),
                          )
                          .toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              titleField,
              Wrap(
                children:
                    ['純米大吟醸', '純米吟醸', '特別純米', '純米', '大吟醸', '吟醸', '特別本醸造', '本醸造']
                        .map(
                          (label) => ActionChip(
                            label: Text(label),
                            onPressed: () {
                              setState(() {
                                _title = label;
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
              createdAtField,
              addSakeButton,
            ],
          ),
        ),
      ),
    );
  }
}
