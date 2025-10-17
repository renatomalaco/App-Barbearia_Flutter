import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller/schedule_controller.dart';
import '../model/schedule_model.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> with SingleTickerProviderStateMixin {
  final ScheduleController _controller = ScheduleController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Define o dia selecionado inicial como o dia de hoje
    _controller.onDaySelected(DateTime.now(), DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Agenda',
                style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),

            // Perfil
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder<ScheduleProfile>(
                valueListenable: _controller.profile,
                builder: (context, profile, child) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(profile.profileImageUrl),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile.classification,
                            style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // Navegação por Abas
            TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.baloo2(),
              labelColor: const Color(0xFF844333),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF844333),
              tabs: const [
                Tab(text: 'Calendário'),
                Tab(text: 'Barbeiros'),
                Tab(text: 'Horários'),
              ],
            ),

            // Conteúdo das Abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba 1: Calendário e Eventos
                  _buildCalendarTab(),
                  // Aba 2: Barbeiros
                  _buildBarbersTab(),
                  // Aba 3: Horários
                  _buildTimeSlotsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        TableCalendar<Event>(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _controller.focusedDay,
          selectedDayPredicate: (day) => isSameDay(_controller.selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _controller.onDaySelected(selectedDay, focusedDay);
            });
          },
          eventLoader: _controller.getEventsForDay,
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: GoogleFonts.baloo2(fontSize: 16),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: GoogleFonts.baloo2(),
            weekendTextStyle: GoogleFonts.baloo2(),
            todayDecoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF844333),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _controller.selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(value[index].title, style: GoogleFonts.baloo2()),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarbersTab() {
    return ListView.builder(
      itemCount: _controller.favoriteBarbers.length,
      itemBuilder: (context, index) {
        final barber = _controller.favoriteBarbers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(barber.avatarUrl),
            ),
            title: Text(barber.name, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
            subtitle: Text(barber.specialty, style: GoogleFonts.baloo2()),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Lógica para selecionar o barbeiro
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotsTab() {
    // Pega o primeiro horário para posicionar a linha vermelha
    final firstSlot = _controller.favoriteTimeSlots.isNotEmpty ? _controller.favoriteTimeSlots.first : null;

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _controller.favoriteTimeSlots.length,
          itemBuilder: (context, index) {
            final slot = _controller.favoriteTimeSlots[index];
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Coluna do Horário
                  SizedBox(
                    width: 60,
                    child: Text(
                      slot.time,
                      style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card do Agendamento
                  Expanded(
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.service,
                              style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'com ${slot.barberName}',
                              style: GoogleFonts.baloo2(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Linha vermelha horizontal posicionada no primeiro agendamento
        if (firstSlot != null)
          Positioned(
            top: 16, // Padding da ListView
            left: 70, // Posição após o texto do horário
            right: 16,
            child: Container(height: 2, color: Colors.red),
          ),
      ],
    );
  }
}