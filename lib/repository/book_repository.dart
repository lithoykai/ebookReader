import 'dart:convert';
import 'dart:io';

import 'package:ebooks/models/book.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BookRepository with ChangeNotifier {
  List<Book> _books = [];
  List<Book> get books => [..._books];
  List<Book> get favoriteBooks =>
      books.where((book) => book.isFavorite).toList();

  Future<void> fetchAllBooks() async {
    final response =
        await http.get(Uri.parse('https://escribo.com/books.json'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _books = data.map((json) => Book.fromJson(json)).toList();

      notifyListeners();
    } else {
      throw Exception('Falha em iniciar os livros.');
    }
  }

  Future<void> downloadAndSaveEpub(Book book) async {
    final response = await http.get(Uri.parse(book.downloadUrl));
    final documentsDirectory = await getApplicationDocumentsDirectory();
    if (response.statusCode == 200) {
      final sanitizedFilename = book.title.replaceAll(RegExp(r'[^\w\s]+'), '');

      final filePath = path.join(documentsDirectory.path, sanitizedFilename);
      book.localSaved = filePath;

      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      notifyListeners();
      print('EPUB file downloaded and saved at: $filePath');
    } else {
      throw Exception('Failed to download EPUB file');
    }
  }
}
