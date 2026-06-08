import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/utils/file_utils.dart';
import '../models/book_model.dart';
import '../repositories/library_repository.dart';

class LibraryController extends ChangeNotifier {
  final LibraryRepository _repository;

  List<BookModel> _books = [];
  bool _isAdmin = false;
  bool _isLoading = false;

  LibraryController(this._repository) {
    _loadBooks();
  }

  List<BookModel> get books => _books;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  Future<void> _loadBooks() async {
    _isLoading = true;
    notifyListeners();

    _books = await _repository.loadBooks();

    // Mevcut dosyaların varlığını kontrol et (silinmiş olabilirler)
    final existingBooks = <BookModel>[];
    bool needsSave = false;
    for (var book in _books) {
      if (await File(book.filePath).exists()) {
        existingBooks.add(book);
      } else {
        needsSave = true; // Dosya yoksa listeden düş
      }
    }

    if (needsSave) {
      _books = existingBooks;
      await _repository.saveBooks(_books);
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleAdmin() {
    _isAdmin = !_isAdmin;
    notifyListeners();
  }

  Future<void> addBook() async {
    try {
      final pickedFilePath = await FileUtils.pickPdfFile();

      if (pickedFilePath != null) {
        _isLoading = true;
        notifyListeners();

        final originalPath = pickedFilePath;
        final fileName = originalPath.split(Platform.pathSeparator).last.split('/').last;

        // Dosyayı belgelerim altına AkilliTahta/Books klasörüne kopyala
        final appDocDir = await getApplicationDocumentsDirectory();
        final separator = Platform.pathSeparator;
        final appBooksDirPath = '${appDocDir.path}${separator}AkilliTahta${separator}Books';
        final appBooksDir = Directory(appBooksDirPath);
        
        if (!await appBooksDir.exists()) {
          await appBooksDir.create(recursive: true);
        }

        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        // Aynı isimde dosya çakışmasını önlemek için ID ekleyelim
        final safeFileName = '${newId}_$fileName';
        final targetPath = '${appBooksDir.path}$separator$safeFileName';

        final file = File(originalPath);
        await file.copy(targetPath);

        final newBook = BookModel(
          id: newId,
          title: fileName.replaceAll('.pdf', ''),
          filePath: targetPath,
        );

        _books.add(newBook);
        await _repository.saveBooks(_books);
      }
    } catch (e) {
      debugPrint('Kitap eklenirken hata oluştu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String id) async {
    final bookIndex = _books.indexWhere((b) => b.id == id);
    if (bookIndex != -1) {
      final book = _books[bookIndex];
      try {
        final file = File(book.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Dosya silinirken hata: $e');
      }
      
      _books.removeAt(bookIndex);
      await _repository.saveBooks(_books);
      notifyListeners();
    }
  }
}
