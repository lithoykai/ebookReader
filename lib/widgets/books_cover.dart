import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebooks/models/book.dart';
import 'package:ebooks/repository/book_repository.dart';
import 'package:ebooks/utils/store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class BooksCover extends StatefulWidget {
  Book book;
  BooksCover(this.book, {super.key});

  @override
  State<BooksCover> createState() => _BooksCoverState();
}

class _BooksCoverState extends State<BooksCover> {
  bool loadingDownload = false;
  bool isEpubDownloaded(String downloadUrl) {
    bool haveBook = widget.book.localSaved?.existsSync() ?? false;
    if (haveBook) {
      haveBook = widget.book.localSaved!.path
          .endsWith('${widget.book.title.replaceAll(' ', '')}.epub');
    }
    return haveBook;
  }

  _openEpubViewer(String path) async {
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: true,
    );

    var locator = await Store.getMap(widget.book.id.toString());
    VocsyEpub.open(
      path,
      lastLocation: EpubLocator.fromJson(locator as Map<String, dynamic>),
    );

    VocsyEpub.locatorStream.listen((locator) async {
      await Store.saveMap(widget.book.id.toString(), jsonDecode(locator));
      widget.book.epubLocator = jsonDecode(locator);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.book.localSaved?.path == null) {
          setState(() {
            loadingDownload = true;
          });
          try {
            await Provider.of<BookRepository>(context, listen: false)
                .downloadAndSaveEpub(widget.book);
          } finally {
            setState(() {
              loadingDownload = false;
            });
          }
        } else {
          _openEpubViewer(widget.book.localSaved!.path);
        }
      },
      splashColor: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: 150,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      widget.book.coverUrl,
                    ),
                    fit: BoxFit.fill,
                    colorFilter: widget.book.hasLocal()
                        ? null
                        : ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    color: widget.book.isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.book.toggleFavorite();
                    });
                  },
                ),
              ),
              loadingDownload
                  ? const Positioned(
                      bottom: 0,
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Colors.blue,
                      )))
                  : const SizedBox()
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            widget.book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.book.author,
            style: TextStyle(
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
