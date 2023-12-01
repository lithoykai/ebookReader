import 'dart:io';

import 'package:ebooks/utils/store.dart';
import 'package:flutter/material.dart';

class Book with ChangeNotifier {
  int id;
  String title;
  String author;
  String coverUrl;
  String downloadUrl;
  bool isFavorite = false;
  File? localSaved;
  Map<String, dynamic>? locator;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.downloadUrl,
    this.isFavorite = false,
    this.localSaved,
    this.locator,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  bool hasLocal() => localSaved != null ? true : false;

  Future<void> toggleFavorite() async {
    _toggleFavorite();
    if (isFavorite == false) {
      if (localSaved != null && await localSaved!.exists()) {
        localSaved!.delete();
        localSaved = null;
      }
    }
    await Store.saveBool(title, isFavorite);
  }

  set epubLocator(Map<String, dynamic> locator) {
    this.locator = locator;
  }

  set local(File localSaved) {
    this.localSaved = localSaved;
  }

  factory Book.fromJson(
    Map<String, dynamic> json,
    Directory filePath,
    bool? isFavorite,
  ) {
    String filename = json['title'];

    File file = File('${filePath.path}/${filename.replaceAll(' ', '')}.epub');
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      localSaved: file.existsSync() ? file : null,
      isFavorite: isFavorite ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'downloadUrl': downloadUrl,
      'localSaved': localSaved?.path,
      'isFavorite': isFavorite
    };
  }
}
