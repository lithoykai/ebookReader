import 'dart:io';

import 'package:flutter/material.dart';

class Book with ChangeNotifier {
  int id;
  String title;
  String author;
  String coverUrl;
  String downloadUrl;
  bool isFavorite = false;
  File? localSaved;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.downloadUrl,
    this.isFavorite = false,
    this.localSaved,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  set local(File localSaved) {
    this.localSaved = localSaved;
  }

  factory Book.fromJson(Map<String, dynamic> json, Directory filePath) {
    String filename = json['title'];

    File file = File('${filePath.path}/${filename.replaceAll(' ', '')}.epub');
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      coverUrl: json['cover_url'],
      downloadUrl: json['download_url'],
      localSaved: file.existsSync() ? file : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['author'] = this.author;
    data['cover_url'] = this.coverUrl;
    data['download_url'] = this.downloadUrl;
    return data;
  }
}
