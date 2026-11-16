
class TarefaModel {
  final int? id;
  final String titulo;
  final String descricao;
  final bool concluida;

  TarefaModel({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });

  // Converte o objeto para Map, para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
    };
  }

  // Converte os dados do banco para um objeto
  factory TarefaModel.fromMap(Map<String, dynamic> map) {
    return TarefaModel(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      concluida: map['concluida'] == 1,
    );
  }
}
