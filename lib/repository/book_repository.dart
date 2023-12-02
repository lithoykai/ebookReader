import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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

  Future<void> initFetchBooks() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await fetchAllBooks();
    } else if (connectivityResult == ConnectivityResult.none) {
      await getDataOffline();
    }
  }

  Future<void> fetchAllBooks() async {
    final response =
        await http.get(Uri.parse('https://escribo.com/books.json'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      var _filePath = await getApplicationDocumentsDirectory();
      _books = await Future.wait(data.map((json) async {
        var isFavorite = await Store.getBool(json['title']);
        Book book = Book.fromJson(json, _filePath, isFavorite);
        downloadAndSaveCover(book);
        return book;
      }).toList());
      saveDataOffline(books);
    } else {
      getDataOffline();
    }
  }

  Future<void> saveDataOffline(List<Book> books) async {
    final booksJson = json.encode(books);
    Store.saveString("books", booksJson);
  }

  Future<void> getDataOffline() async {
    var _filePath = await getApplicationDocumentsDirectory();
    final String booksString = await Store.getString("books");
    final List decode = json.decode(booksString) as List;
    _books = await Future.wait(decode.map((json) async {
      var isFavorite = await Store.getBool(json['title']);
      return Book.fromJson(
        json,
        _filePath,
        isFavorite,
        coverImagePath: await Store.getString('${json['title']}-cover'),
      );
    }).toList());
  }

  Future<void> downloadEpub(Book book) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return;

    final response = await http.get(Uri.parse(book.downloadUrl));
    final documentsDirectory = await getApplicationDocumentsDirectory();
    if (response.statusCode == 200) {
      final fileNameWithoutSpaces = '${book.title.replaceAll(' ', '')}.epub';

      final filePath =
          path.join(documentsDirectory.path, fileNameWithoutSpaces);

      File file = File(filePath);
      book.local = file;
      await file.writeAsBytes(response.bodyBytes);
      await downloadAndSaveCover(book);
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

  Future<void> downloadAndSaveCover(Book book) async {
    final response = await http.get(Uri.parse(book.coverUrl));
    final documentsDirectory = await getApplicationDocumentsDirectory();
    if (response.statusCode == 200) {
      final fileNameWithoutSpaces =
          '${book.title.replaceAll(' ', '')}_cover.jpg';
      final filePath =
          path.join(documentsDirectory.path, fileNameWithoutSpaces);

      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      book.coverImagePath = file.path;
      Store.saveString('${book.title}-cover', file.path);
    } else {
      return;
    }
  }
}
