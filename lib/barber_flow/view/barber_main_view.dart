import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'barber_home_view.dart';
import 'barber_agenda_view.dart';
import 'barber_chat_list_view.dart';
import '../../view/config_view.dart'; // Reutiliza config

class BarberMainView extends StatefulWidget {
  const BarberMainView({super.key});

  @override
  State<BarberMainView> createState() => _BarberMainViewState();
}

class _BarberMainViewState extends State<BarberMainView> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const BarberHomeView(), // Formulário/Card
    const BarberAgendaView(), // Agenda de Clientes
    const BarberChatListView(), // Chat
    const ConfigView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF844333),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Minha Barbearia'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}