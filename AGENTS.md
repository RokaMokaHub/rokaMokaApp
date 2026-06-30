# Repository Guidelines

## Estrutura do Projeto e Organizacao dos Modulos
Este repositorio contem um aplicativo Flutter. O codigo principal fica em `lib/`, separado por responsabilidade: `constants/` para rotas e valores compartilhados, `data/` para repositorios e fontes de dados, `domain/` para providers e services, e `presentation/` para paginas, controllers, widgets e assets do app. Os diretórios `android/` e `ios/` guardam a configuracao nativa. Os testes devem ficar em `test/`, de preferencia espelhando a funcionalidade coberta.

## Comandos de Build, Teste e Desenvolvimento
Execute `flutter pub get` ao atualizar dependencias. Use `flutter run` para iniciar o app em um emulador ou dispositivo conectado. Rode `flutter analyze` para validar o codigo com as regras de `analysis_options.yaml`. Execute `flutter test` para rodar a suite automatizada. Para gerar artefatos, use `flutter build apk` ou `flutter build ios`.

## Estilo de Codigo e Convencoes de Nomes
Siga a formatacao padrao do Dart com indentacao de 2 espacos e rode `dart format .` antes de abrir um PR. O projeto usa `flutter_lints`, entao o codigo deve permanecer sem avisos do analisador. Use nomes de arquivos em `snake_case.dart`, classes e enums em `PascalCase`, e metodos, variaveis e providers em `camelCase`. Componentes reutilizaveis devem ficar em `lib/presentation/widgets/`, enquanto telas completas pertencem a `lib/presentation/pages/`.

## Diretrizes de Testes
Use `flutter_test` para testes unitarios e de widget. Nomeie os arquivos com o sufixo `_test.dart`, por exemplo `test/login_screen_test.dart`. Sempre que alterar autenticacao, navegacao ou estado gerenciado por provider, adicione testes direcionados. A cobertura atual e pequena; novas funcionalidades nao devem depender apenas do teste padrao gerado pelo Flutter.

## Diretrizes de Commit e Pull Request
O historico recente segue prefixos como `feat:`, `fix:`, `build:` e `style:`. Escreva commits curtos, no imperativo, e com uma unica mudanca logica por commit. Pull requests devem trazer um resumo objetivo, issue ou tarefa associada, evidencias de teste com `flutter analyze` e `flutter test`, e capturas de tela ou gravacoes quando houver alteracoes visuais.

## Configuracao e Assets
Ao adicionar novas imagens ou icones, registre os caminhos em `pubspec.yaml` na secao `flutter.assets` antes de usa-los no codigo. Nao versione segredos ou credenciais sensiveis; configuracoes especificas de ambiente devem ficar fora do repositorio, salvo quando forem necessarias para o bootstrap do app.
Sempre que for necessario adicionar ou integrar um novo endpoint no aplicativo, consulte primeiro o Swagger da API em `http://localhost:8080/swagger-ui/index.html#/` para confirmar rota, metodo HTTP, parametros, payloads e respostas antes de implementar.

### Consulta de Endpoints no Swagger
Ao trabalhar com endpoints da API, siga este fluxo:
1. Abra `http://localhost:8080/swagger-ui/index.html#/`.
2. Localize a tag da funcionalidade desejada, como `Autenticacao`, `Usuario`, `Exposicao`, `Obra` ou equivalente.
3. Identifique o endpoint exato e confirme o metodo HTTP (`GET`, `POST`, `PATCH`, `DELETE`).
4. Verifique se a rota possui parametros de `path`, `query` ou `header` e replique esses campos corretamente no app.
5. Confira o `Request body` para validar o DTO esperado, campos obrigatorios, tipos, formatos e se o envio e `application/json` ou `multipart/form-data`.
6. Confira a secao de `Responses` para entender o formato da resposta, codigos HTTP esperados e mensagens de erro que precisam ser tratadas no aplicativo.
7. Verifique se o endpoint exige autenticacao e qual esquema esta descrito em `Authorize`, como `bearer` ou `basic`.
8. Antes de codificar, compare o contrato do Swagger com os models, services, repositories e providers existentes para manter consistencia de nomes e serializacao.

Se houver duvida sobre o contrato real da API, consulte tambem o documento bruto em `http://localhost:8080/v3/api-docs`, pois ele contem o OpenAPI completo usado pela interface do Swagger.

> Observacao: o `/swagger-ui` e o `/v3/api-docs` agora exigem autenticacao Bearer (respondem `401` sem token). Gere um token criando um usuario anonimo via `POST /user/anonymous/create` com `{"userName":"..."}` e envie-o no header `Authorization: Bearer <token>`.
