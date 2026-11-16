
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/tarefa_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = kIsWeb
        ? 'tarefas_web.db'
        : join(await getDatabasesPath(), 'tarefas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descricao TEXT NOT NULL,
            concluida INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> inserirTarefa(TarefaModel tarefa) async {
    final db = await database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  Future<List<TarefaModel>> listarTarefas() async {
    final db = await database;
    final resultado = await db.query('tarefas');
    return resultado.map((map) => TarefaModel.fromMap(map)).toList();
  }

  Future<int> atualizarTarefa(TarefaModel tarefa) async {
    final db = await database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<int> excluirTarefa(int id) async {
    final db = await database;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
