import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF844333);
    const backgroundColor = Colors.white;
    const textColor = Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Bloco Superior: Imagem com Título Sobreposto
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
                Positioned(
                  bottom: 40.0,
                  left: 24.0,
                  right: 24.0,
                  child: Text(
                    'Agende seu corte em segundos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.chonburi(
                      fontSize: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bloco Inferior: Subtítulo e Botões
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 9.0, 24.0, 40.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Bem-vindo ao app do seu barbeiro. Reserve e gerencie facilmente seus compromissos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.actor( 
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Botão de Login com estilo e dimensões atualizadas.
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'login');
                  },
                  // icon: Image.asset(
                  //   'lib/images/logo_white.png',
                  //   height: 40.0,
                  // ),
                  label: Text(
                    'Login',
                    style: GoogleFonts.abyssinicaSil(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Botão de Cadastrar como OutlinedButton.
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 60),
                    side: const BorderSide(color: primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'register'); 
                  },
                  child: Text(
                    'Cadastrar',
                    style: GoogleFonts.abyssinicaSil( 
                      fontSize: 18,
                    ),
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