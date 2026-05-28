# SAFE

Aplicativo acadêmico de segurança no trânsito feito em Flutter, com foco em conscientização, mapa colaborativo, denúncias e quiz gamificado para a campanha Maio Amarelo.

## Funcionalidades

- Home com alertas próximos, estatísticas do mês, score do motorista, feed educativo e desafios Maio Amarelo.
- Mapa colaborativo com filtros, marcação de pontos perigosos, validações e descartes.
- Denúncias com categoria, foto opcional, localização automática e relatório para encaminhamento ao DETRAN.
- Quiz de trânsito com perguntas sobre CTB, sinais, boas práticas, pontuação, streak, ranking e badges.
- Lembrete diário local para responder ao quiz.

## Executar

```sh
flutter pub get
flutter run
```

## Validar

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator
```
