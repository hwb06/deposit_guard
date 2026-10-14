import 'package:sqflite/sqflite.dart';

import '../models/issue_model.dart';
import '../models/issue_severity.dart';
import 'app_database.dart';
import 'db_tables.dart';

class IssueDao {
  const IssueDao(this._appDb);

  final AppDatabase _appDb;

  Future<void> insert(IssueModel issue) async {
    final db = await _appDb.database;
    await db.insert(
      IssueTable.table,
      issue.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(IssueModel issue) async {
    final db = await _appDb.database;
    await db.update(
      IssueTable.table,
      issue.toMap(),
      where: '${IssueTable.id} = ?',
      whereArgs: [issue.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _appDb.database;
    await db.delete(
      IssueTable.table,
      where: '${IssueTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<IssueModel?> getById(String id) async {
    final db = await _appDb.database;
    final rows = await db.query(
      IssueTable.table,
      where: '${IssueTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : IssueModel.fromMap(rows.first);
  }

  Future<List<IssueModel>> getByRental(
      String rentalId, {
        String? room,
        IssueSeverity? severity,
        String? query,
      }) async {
    final db = await _appDb.database;

    final where = <String>['${IssueTable.rentalId} = ?'];
    final args = <Object>[rentalId];

    if (room != null) {
      where.add('${IssueTable.room} = ?');
      args.add(room);
    }
    if (severity != null) {
      where.add('${IssueTable.severity} = ?');
      args.add(severity.name);
    }
    final q = query?.trim();
    if (q != null && q.isNotEmpty) {
      where.add('(${IssueTable.title} LIKE ? OR ${IssueTable.note} LIKE ?)');
      args.addAll(['%$q%', '%$q%']);
    }

    final rows = await db.query(
      IssueTable.table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: '${IssueTable.createdAt} DESC',
    );
    return rows.map(IssueModel.fromMap).toList();
  }

  Future<int> countByRental(String rentalId) async {
    final db = await _appDb.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${IssueTable.table} '
          'WHERE ${IssueTable.rentalId} = ?',
      [rentalId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}