import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'db_tables.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _name = 'deposit_guard.db';
  static const int _version = 1;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _name);
    return openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${RentalTable.table} (
        ${RentalTable.id} TEXT PRIMARY KEY,
        ${RentalTable.name} TEXT NOT NULL,
        ${RentalTable.address} TEXT NOT NULL,
        ${RentalTable.leaseStart} TEXT NOT NULL,
        ${RentalTable.leaseEnd} TEXT NOT NULL,
        ${RentalTable.createdAt} TEXT NOT NULL,
        ${RentalTable.updatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${IssueTable.table} (
        ${IssueTable.id} TEXT PRIMARY KEY,
        ${IssueTable.rentalId} TEXT NOT NULL,
        ${IssueTable.title} TEXT NOT NULL,
        ${IssueTable.room} TEXT NOT NULL,
        ${IssueTable.severity} TEXT NOT NULL,
        ${IssueTable.stage} TEXT NOT NULL,
        ${IssueTable.note} TEXT,
        ${IssueTable.photoPath} TEXT,
        ${IssueTable.createdAt} TEXT NOT NULL,
        ${IssueTable.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${IssueTable.rentalId})
          REFERENCES ${RentalTable.table}(${RentalTable.id})
          ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_issues_rental ON ${IssueTable.table}(${IssueTable.rentalId})',
    );
  }
}