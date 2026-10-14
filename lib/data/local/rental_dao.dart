import 'package:sqflite/sqflite.dart';

import '../models/rental_model.dart';
import 'app_database.dart';
import 'db_tables.dart';

class RentalDao {
  const RentalDao(this._appDb);

  final AppDatabase _appDb;

  Future<void> insert(RentalModel rental) async {
    final db = await _appDb.database;
    await db.insert(
      RentalTable.table,
      rental.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(RentalModel rental) async {
    final db = await _appDb.database;
    await db.update(
      RentalTable.table,
      rental.toMap(),
      where: '${RentalTable.id} = ?',
      whereArgs: [rental.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _appDb.database;
    await db.delete(
      RentalTable.table,
      where: '${RentalTable.id} = ?',
      whereArgs: [id],
    );
  }

  Future<RentalModel?> getById(String id) async {
    final db = await _appDb.database;
    final rows = await db.query(
      RentalTable.table,
      where: '${RentalTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : RentalModel.fromMap(rows.first);
  }

  Future<List<RentalModel>> getAll({String? query}) async {
    final db = await _appDb.database;
    final q = query?.trim();
    final hasQuery = q != null && q.isNotEmpty;

    final rows = await db.query(
      RentalTable.table,
      where: hasQuery
          ? '${RentalTable.name} LIKE ? OR ${RentalTable.address} LIKE ?'
          : null,
      whereArgs: hasQuery ? ['%$q%', '%$q%'] : null,
      orderBy: '${RentalTable.createdAt} DESC',
    );
    return rows.map(RentalModel.fromMap).toList();
  }
}