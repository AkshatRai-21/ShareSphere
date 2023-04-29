import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ShareSphere/core/constants/constants.dart';
import 'package:ShareSphere/core/failure.dart';
import 'package:ShareSphere/core/providers/storage_repository_provider.dart';
import 'package:ShareSphere/core/utilies.dart';
import 'package:ShareSphere/features/auth/controller/auth_controller.dart';
import 'package:ShareSphere/features/community/repository/community_repository.dart';
import 'package:ShareSphere/models/community_model.dart';
import 'package:ShareSphere/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'dart:io';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final getCommunityByNameProvider = StreamProviderFamily((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final getCommunityByPostProvider =
    StreamProviderFamily((ref, String communityName) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByPost(communityName);
});

final searchCommunityProvider = StreamProviderFamily((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully');
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider);

    Either<Failure, void> res;
    if (community.members.contains(user!.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, 'Community left successfully!');
      } else {
        showSnackBar(context, 'Community joined successfully!');
      }
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  Stream<List<Post>> getCommunityByPost(String communityName) {
    return _communityRepository.getCommuntiyPost(communityName);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerfile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null || profileWebFile != null) {
      //communities/profile/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile!,
        webFile: profileWebFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        //Here i'm copying the same community but just changing the avatar
        //with whatever download url we have
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerfile != null || bannerWebFile != null) {
      //communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerfile!,
        webFile: bannerWebFile,
      );

      res.fold(
        (l) => showSnackBar(context, l.message),
        //Here i'm copying the same community but just changing the avatar
        //with whatever download url we have
        (r) => community = community.copyWith(banner: r),
      );
    }

    //In case the user doesnot change any pic then nothing will happen
    //really because nothing changed
    final res = await _communityRepository.editCommunity(community);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Post>> getCommuntiyPost(String communityName) {
    return _communityRepository.getCommuntiyPost(communityName);
  }
}
