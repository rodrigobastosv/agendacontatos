class Contato {
  Contato({
    this.id,
    this.nome,
    this.telefone,
  });

  String id;
  String nome;
  String telefone;

  @override
  String toString() {
    return 'Contato{id: $id, nome: $nome, telefone: $telefone}';
  }
}
