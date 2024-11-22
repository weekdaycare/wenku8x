import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wenku8x/screen/reader/reader_provider.dart';
import 'package:wenku8x/utils/log.dart';

import '../../http/api.dart';

part 'home_provider.freezed.dart';

part 'home_provider.g.dart';

@Collection(ignore: {"catalog", "copyWith"})
@freezed
class BookItem with _$BookItem {
  const BookItem._();

  const factory BookItem({
    required String aid,
    required String name,
    String? cover,
    String? author,
    String? lastChapter,
    String? lastChapterId,
    String? lastUpdate,
    String? status,
    String? intro,
    List<Chapter>? catalog,
    @Default(false) bool isFav,
    @Default(0) int readTime,
  }) = _BookItem;

  @Name("id")
  Id get id {
    return Isar.autoIncrement;
  }
}

const ranks = [
  {"icon": Icons.pan_tool_alt_outlined, "title": "点击"},
  {"icon": Icons.thumb_up_alt_outlined, "title": "推荐"},
  {"icon": Icons.file_open_outlined, "title": "收藏"},
  {"icon": Icons.edit_road_outlined, "title": "字数"},
  {"icon": Icons.school_outlined, "title": "完结"},
  {"icon": Icons.av_timer_outlined, "title": "新书"},
];

class MyBooksNotifier extends StateNotifier<List<BookItem>> {
  MyBooksNotifier() : super([]) {
    _initDB().then((_) => refresh());
  }

  late final Isar _isar;

  Future _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = Isar.openSync([BookItemSchema], directory: dir.path);
  }

  List<BookItem> _getBooksFromDB() {
    var res = _isar.bookItems.where().findAllSync().reversed.toList();
    Log.i(res);
    return res;
  }

  void _writeBooksToDB() {
    final arr = state.reversed.toList();
    _isar.writeTxn(() async {
      await _isar.bookItems.clear();
      for (var element in arr) {
        await _isar.bookItems.put(element);
      }
    });
  }

  void refresh() async {
    state = _getBooksFromDB();
    Log.i(state);
    var res = await API.getShelfBookList();
    if (res != null) {
      for (int i = 0; i < res.length; i++) {
        final book = res[i];
        final matchingBook = state.firstWhere((b) => b.aid == book.aid,
            orElse: () => const BookItem(aid: 'none', readTime: 0, name: ''));

        if (matchingBook.aid != 'none') {
          res[i] = book.copyWith(readTime: matchingBook.readTime);
          Log.i(res[i]);
        }
      }

      state = res;
      _writeBooksToDB();
    }
    state.sort((a, b) => b.readTime.compareTo(a.readTime));
  }

  void addBook(BookItem book) async {
    await API.addToBookShelf(book.aid);
    state = [book, ...state];
    // _writeBooksToDB();
    _isar.writeTxn(() async {
      await _isar.bookItems.put(book);
    });
  }

  void delBook(String aid) {
    API.removeFromBookShelf(aid);
    state = state.where((element) => element.aid != aid).toList();
    _isar.writeTxn(() async {
      await _isar.bookItems.filter().aidEqualTo(aid).deleteFirst();
    });
  }

  void updateBookReadTime(int index, int time) {
    state[index] = state[index].copyWith(readTime: time);
    // trigger update
    state = [...state];
    state.sort((a, b) => b.readTime.compareTo(a.readTime));
    _writeBooksToDB();
  }
}

final myBooksProvider =
    StateNotifierProvider<MyBooksNotifier, List<BookItem>>((ref) {
  return MyBooksNotifier();
});
