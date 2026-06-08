import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class LibraryRepository {
  static const String _booksKey = 'saved_books';

  Future<List<BookModel>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJsonList = prefs.getStringList(_booksKey);
    if (booksJsonList == null) return [];

    return booksJsonList.map((jsonStr) => BookModel.fromJson(jsonStr)).toList();
  }

  Future<void> saveBooks(List<BookModel> books) async {
    final prefs = await SharedPreferences.getInstance();
    final booksJsonList = books.map((book) => book.toJson()).toList();
    await prefs.setStringList(_booksKey, booksJsonList);
  }
}
