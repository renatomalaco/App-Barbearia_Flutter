// Local do arquivo: lib/controller/barbershop_detail_controller.dart

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
    'Barba & Navalha': BarbershopDetail(
        name: 'Barba & Navalha',
        imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
        description: 'Especialistas em barbas e cortes tradicionais, oferecendo uma experiência premium para o homem moderno.',
        openingHours: '10:00 - 21:00',
        address: 'Av. dos Barbeiros, 456',
        cityState: 'Rio de Janeiro, RJ',
        zipCode: '20000-000',
        rating: '4.9',
        reviewCount: '3.1k'
    ),
    'Corte do Rei': BarbershopDetail(
        name: 'Corte do Rei',
        imageUrl: 'https://images.unsplash.com/photo-1536520002442-39764a41e987?q=80&w=1000&auto=format&fit=crop',
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