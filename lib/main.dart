import 'package:ebooks/pages/home_page.dart';
import 'package:ebooks/repository/book_repository.dart';
import 'package:ebooks/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const EbookMain());
}

class EbookMain extends StatelessWidget {
  const EbookMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => BookRepository(),
      child: MaterialApp(
        title: 'Ebook Reader',
        routes: {
          AppRoutes.HOME_PAGE: (ctx) => const HomePage(),
        },
      ),
    );
  }
}
