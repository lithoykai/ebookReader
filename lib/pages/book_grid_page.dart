import 'package:ebooks/models/book.dart';
import 'package:ebooks/repository/book_repository.dart';
import 'package:ebooks/widgets/books_cover.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookGridPage extends StatelessWidget {
  bool showFavoriteOnly;
  BookGridPage(this.showFavoriteOnly, {super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookRepository>(context);
    final List<Book> loadedBooks =
        showFavoriteOnly ? provider.favoriteBooks : provider.books;
    return loadedBooks.isEmpty
        ? const Center(
            child: Text(
            'Não há nenhum livro disponível',
          ))
        : GridView(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 0.7,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            children: loadedBooks.map((book) {
              return BooksCover(book);
            }).toList());
  }
}
