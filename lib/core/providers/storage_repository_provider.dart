import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ShareSphere/core/failure.dart';
import 'package:ShareSphere/core/providers/firebase_providers.dart';
import 'dart:io';

import 'package:ShareSphere/core/type_def.dart';

//class that we have created which will allow us to store a file
//without having to writemore code
final storageRepositoryProvider = Provider(
  (ref) =>
      //Instance of the class which will aloow us to store
      StorageRepository(
    firebaseStorage: ref.watch(StorageProvider),
  ),
);

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile(
      {required String path,
      required String id,
      required File file,
      required Uint8List? webFile}) async {
    try {
      //users/banner/123
      final ref = _firebaseStorage.ref().child(path).child(id);

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(webFile!);
      } else {
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;

      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
