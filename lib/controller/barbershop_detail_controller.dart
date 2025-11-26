import '../model/barbershop_detail_model.dart';

class BarbershopDetailController {
  // Este mapa armazena os dados detalhados. A chave é o nome da barbearia.
  final Map<String, BarbershopDetail> _details = {
    'Barbearia New Cut': BarbershopDetail(
      name: 'Barbearia New Cut',
      imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
      description: 'A barbearia "O New Cut" é um santuário dedicado à arte da barbearia tradicional, resgatando a elegância e a precisão dos cortes que definiram gerações. Inspirada na atmosfera das décadas de 1940 e 1950, nosso espaço não é apenas um local para aparar o cabelo e a barba, mas um ponto de encontro onde o homem moderno pode se desconectar da rotina e vivenciar um serviço de excelência.',
      openingHours: '09:00 - 20:00',
      address: 'Rua das Tesouras, 123',
      cityState: 'São Paulo, SP',
      zipCode: '01000-000',
      rating: '4.8',
      reviewCount: '2.4k'
    ),
    'Barbearia Old School': BarbershopDetail(
        name: 'Barbearia Old School',
        imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YmFyYmVyc2hvcHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600',
        description: 'Especialistas em barbas e cortes tradicionais, oferecendo uma experiência premium para o homem moderno.',
        openingHours: '10:00 - 21:00',
        address: 'Av. dos Barbeiros, 456',
        cityState: 'Rio de Janeiro, RJ',
        zipCode: '20000-000',
        rating: '4.9',
        reviewCount: '3.1k'
    ),
    'Classic Cuts Barbershop': BarbershopDetail(
        name: 'Classic Cuts Barbershop',
        imageUrl: 'https://images.unsplash.com/photo-1693755807658-17ce5331aacb?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGJhcmJlcnNob3B8ZW58MHwwfDB8fHww&auto=format&fit=crop&q=60&w=600',
        description: 'O tratamento que você merece, com os melhores profissionais e produtos do mercado.',
        openingHours: '08:30 - 19:30',
        address: 'Praça da Coroa, 789',
        cityState: 'Belo Horizonte, MG',
        zipCode: '30000-000',
        rating: '4.7',
        reviewCount: '1.8k'
    ),
  };

  // Método para buscar os detalhes com base no nome da barbearia
  BarbershopDetail? getDetailsFor(String name) {
    return _details[name];
  }
}