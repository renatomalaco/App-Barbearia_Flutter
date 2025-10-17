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
                  // Aba 2: Barbeiros (Placeholder)
                  Center(child: Text('Lista de Barbeiros', style: GoogleFonts.baloo2())),
                  // Aba 3: Horários (Placeholder)
                  Center(child: Text('Lista de Horários', style: GoogleFonts.baloo2())),
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
}