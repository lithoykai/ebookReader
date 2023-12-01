import 'package:ebooks/pages/book_grid_page.dart';
import 'package:ebooks/repository/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        body: SafeArea(
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
                    child: Text(
                      'Todos',
                      style: TextStyle(
                          color: _showFavoriteOnly ? null : Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showFavoriteOnly = true;
                      });
                    },
                    child: Text(
                      'Favoritos',
                      style: TextStyle(
                          color: _showFavoriteOnly ? Colors.blue : null),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future: Provider.of<BookRepository>(context, listen: false)
                      .fetchAllBooks(),
                  builder: (context, snapashot) {
                    if (snapashot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapashot.error != null) {
                      return const Center(
                        child: Text('Ocorreu um erro!'),
                      );
                    } else {
                      return BookGridPage(_showFavoriteOnly);
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
