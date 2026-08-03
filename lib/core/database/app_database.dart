import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get purchasePrice => real()();
  RealColumn get sellingPrice => real()();
  IntColumn get quantity => integer()();
  TextColumn get barcode => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get branchId => text().nullable()();
}

class Sales extends Table {
  TextColumn get id => text()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get workerId => text()();
  TextColumn get branchId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
}

class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
}

class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();
  RealColumn get originalAmount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get branchId => text().nullable()();
}

class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  RealColumn get dailySales => real().withDefault(const Constant(0))();
  IntColumn get workerCount => integer().withDefault(const Constant(0))();
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Promotions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get discount => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Products, Sales, SaleItems, Debts, Branches, Customers, Promotions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createEnrollmentTables();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(promotions);
          }
          if (from < 3) {
            await _createEnrollmentTables();
          }
        },
      );

  Future<void> _createEnrollmentTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS product_images (
        id TEXT PRIMARY KEY NOT NULL,
        product_id TEXT NOT NULL,
        local_path TEXT NOT NULL,
        source_url TEXT,
        width INTEGER,
        height INTEGER,
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_product_images_pid ON product_images(product_id)');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS product_drafts (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        barcode TEXT,
        category TEXT,
        purchase_price REAL,
        selling_price REAL,
        quantity INTEGER,
        description TEXT,
        source_type TEXT NOT NULL,
        source_image_path TEXT,
        extracted_data TEXT,
        completion_percent INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS product_embeddings (
        id TEXT PRIMARY KEY NOT NULL,
        product_id TEXT NOT NULL,
        embedding_json TEXT NOT NULL,
        image_path TEXT NOT NULL,
        version INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_product_embeddings_pid ON product_embeddings(product_id)');
  }

  Future<void> reset() async {
    await close();
    final dbFile = await _databaseFile();
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    _instance = null;
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await _dbDirectory();
      final file = File(p.join(dbFolder.path, 'ai_store_assistant.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  static Future<File> _databaseFile() async {
    final dbFolder = await _dbDirectory();
    return File(p.join(dbFolder.path, 'ai_store_assistant.db'));
  }

  static Future<Directory> _dbDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir;
    } on MissingPluginException {
      final fallback = Directory.current;
      if (!fallback.existsSync()) {
        fallback.createSync(recursive: true);
      }
      return fallback;
    } on PlatformException {
      final fallback = Directory.current;
      if (!fallback.existsSync()) {
        fallback.createSync(recursive: true);
      }
      return fallback;
    }
  }
}
