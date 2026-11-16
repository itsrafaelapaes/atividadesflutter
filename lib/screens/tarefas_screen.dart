
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa_model.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  List<TarefaModel> tarefas = [];

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final dados = await DatabaseHelper.instance.listarTarefas();

    if (!mounted) return;

    setState(() {
      tarefas = dados;
    });
  }

  Future<void> salvarTarefa({TarefaModel? tarefa}) async {
    tituloController.text = tarefa?.titulo ?? '';
    descricaoController.text = tarefa?.descricao ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                ),
              ),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tituloController.text.trim().isEmpty ||
                    descricaoController.text.trim().isEmpty) {
                  return;
                }

                final novaTarefa = TarefaModel(
                  id: tarefa?.id,
                  titulo: tituloController.text.trim(),
                  descricao: descricaoController.text.trim(),
                  concluida: tarefa?.concluida ?? false,
                );

                if (tarefa == null) {
                  await DatabaseHelper.instance.inserirTarefa(novaTarefa);
                } else {
                  await DatabaseHelper.instance.atualizarTarefa(novaTarefa);
                }

                if (!context.mounted) return;

                Navigator.pop(context);
                await carregarTarefas();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> alternarConclusao(TarefaModel tarefa) async {
    final atualizada = TarefaModel(
      id: tarefa.id,
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      concluida: !tarefa.concluida,
    );

    await DatabaseHelper.instance.atualizarTarefa(atualizada);
    await carregarTarefas();
  }

  Future<void> excluirTarefa(int id) async {
    await DatabaseHelper.instance.excluirTarefa(id);
    await carregarTarefas();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Tarefas'),
        centerTitle: true,
      ),
      body: tarefas.isEmpty
          ? const Center(
              child: Text('Nenhuma tarefa cadastrada.'),
            )
          : ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Checkbox(
                      value: tarefa.concluida,
                      onChanged: (_) => alternarConclusao(tarefa),
                    ),
                    title: Text(
                      tarefa.titulo,
                      style: TextStyle(
                        decoration: tarefa.concluida
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(tarefa.descricao),
                    trailing: PopupMenuButton<String>(
                      onSelected: (valor) {
                        if (valor == 'editar') {
                          salvarTarefa(tarefa: tarefa);
                        } else if (valor == 'excluir') {
                          excluirTarefa(tarefa.id!);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'excluir',
                          child: Text('Excluir'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => salvarTarefa(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
