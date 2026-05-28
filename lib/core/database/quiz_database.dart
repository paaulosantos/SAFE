import 'package:safe/core/models/quiz.dart';

class QuizDatabase {
  static final List<QuizQuestion> allQuestions = [
    // CTB - Prioridades e Pedestres
    QuizQuestion(
      id: 'q001',
      question:
          'Qual é o procedimento correto ao se aproximar de uma faixa de pedestre sem semáforo?',
      options: [
        'Acelerar para passar antes que o pedestre coloque o pé na faixa',
        'Reduzir a velocidade e dar preferência total ao pedestre',
        'Buzinar para alertar que você não pretende parar',
        'Manter a velocidade constante se o pedestre estiver parado',
      ],
      correctAnswerIndex: 1,
      explanation:
          'De acordo com o CTB, o pedestre tem prioridade sobre os veículos motorizados. Reduzir a velocidade não é apenas uma regra, mas um ato que salva vidas.',
      category: 'ctb',
      difficulty: 1,
    ),

    // CTB - Distância de Segurança
    QuizQuestion(
      id: 'q002',
      question:
          'Qual deve ser a distância de segurança entre veículos em uma via urbana a 60 km/h?',
      options: [
        '1 metro',
        '2 metros',
        'Pelo menos 40 metros',
        'A distância não importa se você estiver atento',
      ],
      correctAnswerIndex: 2,
      explanation:
          'A regra dos "2 segundos" é fundamental: mantenha uma distância de segurança equivalente ao espaço percorrido em 2 segundos. A 60 km/h, isso representa aproximadamente 33-40 metros.',
      category: 'ctb',
      difficulty: 2,
    ),

    // Sinais de Trânsito
    QuizQuestion(
      id: 'q003',
      question: 'O que significa um semáforo verde piscante para veículos?',
      options: [
        'Que há pedestres cruzando',
        'Que você tem pouco tempo para passar',
        'Que há um radar próximo',
        'Que o semáforo está com defeito',
      ],
      correctAnswerIndex: 1,
      explanation:
          'O semáforo verde piscante indica que o tempo de passagem está terminando. Você tem aproximadamente 4 segundos para atravessar. Prepare-se para reduzir a velocidade.',
      category: 'sinais',
      difficulty: 2,
    ),

    // Boas Práticas
    QuizQuestion(
      id: 'q004',
      question:
          'Em caso de perda de freios em uma descida, qual é o procedimento correto?',
      options: [
        'Puxar o freio de mão com força máxima',
        'Engrenar uma marcha baixa e usar o freio de mão progressivamente',
        'Desligar o motor',
        'Sair da via em alta velocidade',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Ao perder os freios, você deve engatar uma marcha baixa (2ª ou 1ª) para usar o motor como freio e aplicar o freio de mão de forma progressiva. Isso evita travamento e perda de controle.',
      category: 'praticas',
      difficulty: 3,
    ),

    // Sinais de Trânsito - Placa
    QuizQuestion(
      id: 'q005',
      question: 'O que significa uma placa vermelha com um círculo?',
      options: [
        'Proibição ou Restrição',
        'Aviso de Perigo',
        'Indicação obrigatória',
        'Informação geral',
      ],
      correctAnswerIndex: 0,
      explanation:
          'As placas vermelhas com círculo indicam proibição ou restrição. Exemplo: Proibido Estacionar, Proibido Virar à Esquerda, etc.',
      category: 'sinais',
      difficulty: 1,
    ),

    // CTB - Bebida Alcoólica
    QuizQuestion(
      id: 'q006',
      question:
          'Qual é o limite legal de álcool no sangue para dirigir no Brasil?',
      options: [
        '0,1% (1 grama por litro)',
        '0,05% (meio grama por litro) - ZERO para infratores reincidentes',
        '0,2% (2 gramas por litro)',
        'Não existe limite, qualquer quantidade é permitida',
      ],
      correctAnswerIndex: 1,
      explanation:
          'O limite legal é 0,05% ou 0,5 grama por litro de sangue. Para reincidentes, o limite é zero. Dirigir alcoolizado é uma das principais causas de acidentes fatais.',
      category: 'ctb',
      difficulty: 1,
    ),

    // Boas Práticas - Cansaço
    QuizQuestion(
      id: 'q007',
      question: 'Qual é o risco mais comum causado por dirigir cansado?',
      options: [
        'Aumento de velocidade involuntário',
        'Adormecer ao volante',
        'Aceleração brusca',
        'Aquaplanagem',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Dirigir cansado aumenta drasticamente o risco de acidentes. O cansaço reduz reflexos, concentração e julgamento. A cada 2 horas de dirigida, faça uma pausa de 15 minutos.',
      category: 'praticas',
      difficulty: 2,
    ),

    // Sinais de Trânsito - Seta
    QuizQuestion(
      id: 'q008',
      question:
          'O que você deve fazer ao ver um veículo com a seta de mudança de faixa acionada?',
      options: [
        'Acelerar para bloquear a mudança de faixa',
        'Reduzir velocidade e facilitar a mudança',
        'Buzinar para alertar o motorista',
        'Ignorar e continuar na mesma velocidade',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Quando outro veículo sinaliza a mudança de faixa, você deve reduzir a velocidade e facilitar essa manobra. É uma atitude de segurança que previne acidentes.',
      category: 'sinais',
      difficulty: 1,
    ),

    // CTB - Celular ao Volante
    QuizQuestion(
      id: 'q009',
      question: 'Qual é a multa por usar celular ao dirigir no Brasil?',
      options: [
        'R\$ 100',
        'R\$ 293,47 (infração gravíssima)',
        'R\$ 50',
        'R\$ 500',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Usar celular ao dirigir é uma infração gravíssima com multa de R\$ 293,47, 7 pontos na carteira e possível retenção do veículo. Reduz drasticamente a atenção e tempo de reação.',
      category: 'ctb',
      difficulty: 1,
    ),

    // Boas Práticas - Manutenção
    QuizQuestion(
      id: 'q010',
      question: 'Com que frequência você deve verificar a pressão dos pneus?',
      options: [
        'Uma vez por ano',
        'A cada 1.000 km ou mensalmente',
        'Apenas quando notar que está baixo',
        'Nunca, o pneu se auto-regula',
      ],
      correctAnswerIndex: 1,
      explanation:
          'A pressão dos pneus deve ser verificada regularmente (a cada 1.000 km ou mensalmente). Pneus com pressão incorreta afetam a segurança, economia de combustível e durabilidade.',
      category: 'praticas',
      difficulty: 1,
    ),

    // Sinais - Faixa Contínua
    QuizQuestion(
      id: 'q011',
      question: 'O que significa uma faixa branca contínua na pista?',
      options: [
        'Você pode ultrapassar outro veículo',
        'Proibido ultrapassar outro veículo',
        'Apenas para estacionamento',
        'Via de mão dupla',
      ],
      correctAnswerIndex: 1,
      explanation:
          'A faixa branca contínua significa PROIBIDO ultrapassar. A faixa branca tracejada permite ultrapassagens. Respeitar essas sinalizações é fundamental para evitar acidentes frontais.',
      category: 'sinais',
      difficulty: 1,
    ),

    // CTB - Cinto de Segurança
    QuizQuestion(
      id: 'q012',
      question: 'Qual é a multa por não usar cinto de segurança?',
      options: [
        'R\$ 50',
        'R\$ 195,23 (infração grave)',
        'R\$ 100',
        'Não há multa, é apenas recomendação',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Não usar cinto de segurança resulta em multa de R\$ 195,23 e 5 pontos na carteira. O cinto reduz em até 50% o risco de morte em acidentes graves.',
      category: 'ctb',
      difficulty: 1,
    ),

    // Boas Práticas - Rodovia
    QuizQuestion(
      id: 'q013',
      question: 'Em uma rodovia com chuva, qual é a melhor atitude?',
      options: [
        'Aumentar a velocidade para não molhar o carro',
        'Reduzir velocidade e aumentar distância de segurança',
        'Manter a velocidade normal',
        'Desligar os faróis para economizar bateria',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Em condições de chuva, reduz a aderência dos pneus em até 50%. Reduza a velocidade em pelo menos 40% e aumente a distância de segurança. Acenda os faróis baixos.',
      category: 'praticas',
      difficulty: 2,
    ),

    // Sinais - Sinal de Parada
    QuizQuestion(
      id: 'q014',
      question: 'O que significa a placa de "PARADA OBRIGATÓRIA"?',
      options: [
        'Pode passar se não houver veículos próximos',
        'Deve parar completamente, mesmo que não haja outro veículo',
        'Desacelerar mas pode seguir se não ver veículos',
        'Parar apenas em horários de pico',
      ],
      correctAnswerIndex: 1,
      explanation:
          'A placa PARADA OBRIGATÓRIA (STOP) exige uma parada completa do veículo. Você deve parar totalmente, mesmo que não haja outros veículos, pois há redução de visibilidade.',
      category: 'sinais',
      difficulty: 1,
    ),

    // CTB - Excesso de Velocidade
    QuizQuestion(
      id: 'q015',
      question:
          'Qual é a multa por excesso de velocidade de 20 km/h acima do limite?',
      options: [
        'R\$ 130,16 (infração média)',
        'R\$ 293,47 (infração gravíssima)',
        'R\$ 88,38 (infração leve)',
        'Apenas advertência verbal',
      ],
      correctAnswerIndex: 2,
      explanation:
          'Excesso de velocidade até 20 km/h acima do limite é infração leve com multa de R\$ 88,38. Acima disso, aumenta para grave e depois gravíssima, com mais pontos na carteira.',
      category: 'ctb',
      difficulty: 2,
    ),
  ];

  static List<QuizQuestion> getRandomQuestions({int count = 5}) {
    final shuffled = List<QuizQuestion>.from(allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }

  static List<QuizQuestion> getQuestionsByCategory(
    String category, {
    int count = 5,
  }) {
    final filtered = allQuestions.where((q) => q.category == category).toList()
      ..shuffle();
    return filtered.take(count).toList();
  }
}
