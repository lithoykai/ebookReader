import 'dart:convert';
import 'dart:io';

import 'package:ebooks/models/book.dart';
import 'package:ebooks/utils/store.dart';
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
      var _filePath = await getApplicationDocumentsDirectory();
      _books = await Future.wait(data.map((json) async {
        var isFavorite = await Store.getBool(json['title']);
        return Book.fromJson(
          json,
          _filePath,
          isFavorite,
        );
      }).toList());
    } else {
      throw Exception('Falha em iniciar os livros.');
    }
  }

  Future<void> downloadAndSaveEpub(Book book) async {
    final response = await http.get(Uri.parse(book.downloadUrl));
    final documentsDirectory = await getApplicationDocumentsDirectory();
    if (response.statusCode == 200) {
      final fileNameWithoutSpaces = '${book.title.replaceAll(' ', '')}.epub';

      final filePath =
          path.join(documentsDirectory.path, fileNameWithoutSpaces);

      File file = File(filePath);
      book.local = file;
      await file.writeAsBytes(response.bodyBytes);
      notifyListeners();
    } else {
      throw Exception('Falha ao baixar o livro.');
    }
  }

  void deleteEpub(Book book) async {
    if (book.localSaved != null && await book.localSaved!.exists()) {
      book.localSaved!.delete();
      notifyListeners();
    } else {
      return;
    }
  }
}
