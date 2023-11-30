import 'package:ebooks/models/book.dart';
import 'package:ebooks/repository/book_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class BooksCover extends StatefulWidget {
  Book book;
  BooksCover(this.book);

  @override
  State<BooksCover> createState() => _BooksCoverState();
}

class _BooksCoverState extends State<BooksCover> {
  bool loadingDownload = false;
  bool isEpubDownloaded(String downloadUrl) {
    String filename = '${widget.book.title.replaceAll(' ', '')}.epub';

    bool haveBook = widget.book.localSaved?.existsSync() ?? false;
    if (haveBook) {
      haveBook = widget.book.localSaved!.path
          .endsWith('${widget.book.title.replaceAll(' ', '')}.epub');
    }

    return haveBook;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.book.localSaved?.path == null) {
          loadingDownload = true;
          Provider.of<BookRepository>(context, listen: false)
              .downloadAndSaveEpub(widget.book)
              .then((value) {
            setState(() {
              loadingDownload = false;
            });
          });
        } else {
          VocsyEpub.setConfig(
            themeColor: Theme.of(context).primaryColor,
            identifier: "iosBook",
            scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
            allowSharing: true,
            enableTts: true,
            nightMode: true,
          );
          // get current locator
          VocsyEpub.locatorStream.listen((locator) {
            print('LOCATOR: $locator');
          });
          print(widget.book.localSaved!.path.length);
          await VocsyEpub.openAsset(
            widget.book.localSaved!.path,
            lastLocation: EpubLocator.fromJson({
              "bookId": "2239",
              "href": "/OEBPS/ch06.xhtml",
              "created": 1539934158390,
              "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
            }),
          );
        }
      },
      splashColor: Theme.of(context).primaryColor,
      // borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          loadingDownload
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Container(
                      height: 200,
                      width: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.book.coverUrl),
                          fit: BoxFit.fill,
                          colorFilter: widget.book.localSaved != null
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
                          color: widget.book.isFavorite
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.book.toggleFavorite();
                          });
                        },
                      ),
                    ),
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
