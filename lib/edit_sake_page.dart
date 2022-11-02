import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exif/exif.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:osake/sake_list_page.dart';

class EditSakePage extends StatefulWidget {
  const EditSakePage({super.key, required this.sake});

  final sake;

  @override
  State<EditSakePage> createState() => _EditSakePageState();
}

class _EditSakePageState extends State<EditSakePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _titleController = TextEditingController();
  File? _image;
  final _createdAtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _brandController.text = widget.sake.get('brand');
    _titleController.text = widget.sake.get('title');
    _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm')
        .format(widget.sake.get('createdAt').toDate());
  }

  @override
  void dispose() {
    _brandController.dispose();
    _titleController.dispose();
    _createdAtController.dispose();
    super.dispose();
  }

  _onEditImage() async {
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
      _createdAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(
        DateFormat('yyyy:MM:dd HH:mm:ss')
            .parse(data['Image DateTime'].toString()),
      );
    });
  }

  _onEditSake() async {
    if (!_formKey.currentState!.validate()) return;
    final brand = _brandController.text;
    final title = _titleController.text;
    final createdAt =
        Timestamp.fromDate(DateTime.parse(_createdAtController.text));
    final updatedAt = Timestamp.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('sakes')
        .doc(widget.sake.id)
        .update(<String, dynamic>{
      'brand': brand,
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    });

    if (_image != null) {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('sakes')
          .child(widget.sake.id)
          .child('image');
      await imageRef.putFile(_image!);
      final imageURL = await imageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('sakes')
          .doc(widget.sake.id)
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
              if (widget.sake.get('imageURL').isNotEmpty) {
                await FirebaseStorage.instance
                    .ref()
                    .child('users')
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .child('sakes')
                    .child(widget.sake.id)
                    .child('image')
                    .delete();
              }

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('sakes')
                  .doc(widget.sake.id)
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
    final imageField = _image != null
        ? GestureDetector(
            child: Image.file(_image!),
            onTap: _onEditImage,
          )
        : widget.sake.get('imageURL').isNotEmpty
            ? GestureDetector(
                child: Image.network(widget.sake.get('imageURL')),
                onTap: _onEditImage,
              )
            : IconButton(
                onPressed: _onEditImage,
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
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter some text' : null,
    );
    final editSakeButton = ElevatedButton(
      onPressed: _onEditSake,
      child: const Text('Edit sake'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('osake'),
        actions: <Widget>[
          deleteSakeButton,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              children: <Widget>[
                imageField,
                brandField,
                titleField,
                createdAtField,
                editSakeButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
