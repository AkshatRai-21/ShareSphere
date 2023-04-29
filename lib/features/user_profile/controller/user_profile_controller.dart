import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ShareSphere/core/enums/enums.dart';
import 'package:ShareSphere/core/providers/storage_repository_provider.dart';
import 'package:ShareSphere/core/utilies.dart';
import 'package:ShareSphere/features/auth/controller/auth_controller.dart';
import 'package:ShareSphere/features/user_profile/repository/user_profile_repository.dart';
import 'package:ShareSphere/models/post_model.dart';
import 'dart:io';
import 'package:ShareSphere/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final getUserPostsProvider = StreamProviderFamily((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editCommunity({
    required File? profileFile,
    required File? bannerfile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    if (profileFile != null || profileWebFile != null) {
      //communities/profile/memes
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile!,
        webFile: profileWebFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        //Here i'm copying the same community but just changing the avatar
        //with whatever download url we have
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    if (bannerfile != null || bannerWebFile != null) {
      //communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerfile!,
        webFile: bannerWebFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        //Here i'm copying the same community but just changing the avatar
        //with whatever download url we have
        (r) => user = user.copyWith(banner: r),
      );
    }

    //In case the user doesnot change any pic then nothing will happen
    //really because nothing changed
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        //What do i want to update?
        //Well i just want to update the userprovider with the new
        //usermodel that we have because i want my providers to
        //have the latest idea
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
