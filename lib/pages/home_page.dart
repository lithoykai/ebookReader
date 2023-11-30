import 'package:ebooks/pages/book_grid_page.dart';
import 'package:ebooks/repository/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FilterOptions {
  Favorite,
  All,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showFavoriteOnly = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebook Reader'),
      ),
      body: FutureBuilder(
        future:
            Provider.of<BookRepository>(context, listen: false).fetchAllBooks(),
        builder: (context, snapashot) {
          if (snapashot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapashot.error != null) {
            return Center(
              child: Text('Ocorreu um erro!'),
            );
          } else {
            return SafeArea(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showFavoriteOnly = false;
                          });
                        },
                        child: const Text(
                          'Todos',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showFavoriteOnly = true;
                          });
                        },
                        child: const Text('Favoritos'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: BookGridPage(_showFavoriteOnly),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
