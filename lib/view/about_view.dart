import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF844333);
    const backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Bloco Superior: Imagem com Título Sobreposto e o texto
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  child: Image.asset(
                    'lib/images/barbeiro.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradiente para melhorar a legibilidade do texto
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60.0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'lib/images/logo_white.png',
                    height: 180,
                  ),
                ),
                Positioned(
                  bottom: 150.0, 
                  left: 24.0,
                  right: 24.0,
                  child: Text(
                    'Esse aplicativo foi criado para ajudar barbeiros/cabelereiros e clientes a se conectarem. O aplicativo visa melhorar a eficiencia do barbeiro nos agendamentos e atendimentos, utilizando uma agenda com todas informações necessárias do cliente, assim como, facilitar o acesso dos clientes na busca de barbeiros e horários flexiveis.\n\n Esse aplicativo vai ajudar pessoas a agendar seus cortes de maneira prática, fácil e rápida. E vai ajudar o barbeiro com seu atendimento, melhorando sua comunicação com os clientes por via das mensagens e sua agenda por meio do calendario de agendamentos. \n\n Integrantes: Renato Malaco de Oliveira e Isabela de Souza Oliveira',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.abyssinicaSil(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          // Navega de volta para a tela principal ('list') e remove
                          // todas as rotas acima dela, garantindo o retorno à tela
                          // que contém as configurações.
                          Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false);
                        },
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voltar',
                        style: GoogleFonts.abyssinicaSil(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}