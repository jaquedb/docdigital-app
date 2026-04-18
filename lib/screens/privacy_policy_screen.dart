import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Política de Privacidade"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '''
Política de Privacidade - DocDigital

1. Coleta de Dados
Coletamos informações fornecidas pelo usuário, como nome, email e documentos enviados para armazenamento.

2. Uso dos Dados
Os dados são utilizados exclusivamente para permitir a organização e gerenciamento de documentos pessoais no aplicativo.

3. Armazenamento
Seus dados são armazenados de forma segura e não são compartilhados com terceiros.

4. Segurança
Adotamos medidas de segurança para proteger suas informações contra acesso não autorizado.

5. Direitos do Usuário
Você pode solicitar a exclusão dos seus dados a qualquer momento através do aplicativo.

6. Contato
Em caso de dúvidas, entre em contato pelo suporte do aplicativo.
            ''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}