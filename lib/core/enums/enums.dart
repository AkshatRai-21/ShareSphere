import 'package:flutter/material.dart';

enum ThemeMode {
  light,
  dark,
}

enum UserKarma {
  comment(1),
  textPost(1),
  linkPost(1),
  imagePost(3),
  awardPost(5),
  deletePost(-1);

  final int karma;
  const UserKarma(this.karma);
}
