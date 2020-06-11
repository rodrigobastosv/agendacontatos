import 'package:agendacontatos/contato.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListPage(),
    );
  }
}

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('agenda').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final querySnapshot = snapshot.data;
            final documentos = querySnapshot.documents;
            final contatos = [];
            for (var documento in documentos) {
              contatos.add(
                Contato(
                  id: documento.documentID,
                  nome: documento.data['nome'],
                  telefone: documento.data['telefone'],
                ),
              );
            }
            return ListView.builder(
              itemBuilder: (_, i) => GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddPage(contatos[i]),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(contatos[i].nome),
                  subtitle: Text(contatos[i].telefone),
                  trailing: GestureDetector(
                    onTap: () async {
                      await Firestore.instance
                          .collection('agenda')
                          .document(contatos[i].id)
                          .delete();
                    },
                    child: Icon(Icons.delete),
                  ),
                ),
              ),
              itemCount: contatos.length,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddPage(null),
            ),
          );
        },
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  AddPage(this.contato);

  final Contato contato;

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String _nome;
  String _telefone;
  bool isEdit;

  GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    isEdit = widget.contato != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                initialValue: widget.contato?.nome,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nome',
                ),
                validator: (nome) => nome.isEmpty ? 'Campo Obrigatório' : null,
                onSaved: (nome) => _nome = nome,
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: widget.contato?.telefone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Telefone',
                ),
                validator: (telefone) =>
                    telefone.isEmpty ? 'Campo Obrigatório' : null,
                onSaved: (telefone) => _telefone = telefone,
              ),
              SizedBox(height: 12),
              RaisedButton(
                color: Colors.blue,
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  final form = _key.currentState;
                  if (form.validate()) {
                    form.save();
                    if (isEdit) {
                      await Firestore.instance
                          .collection('agenda')
                          .document(widget.contato.id)
                          .setData({
                        'nome': _nome,
                        'telefone': _telefone,
                      });
                    } else {
                      await Firestore.instance.collection('agenda').add({
                        'nome': _nome,
                        'telefone': _telefone,
                      });
                    }
                    form.reset();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
