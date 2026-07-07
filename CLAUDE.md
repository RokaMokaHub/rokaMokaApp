# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Roká Móka is a Flutter gamification app for museum visitors in Pelotas, Brazil. Visitors scan QR codes on artworks to earn stars, unlock information, and collect emblems by completing exhibition collections.

## Commands

```bash
# Install/update dependencies
flutter pub get

# Run on emulator/device
flutter run

# Lint and static analysis
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Architecture

The app follows a layered structure under `lib/`:

- **`constants/`** — Shared values: `routes.dart` (named route constants), `colors.dart`, `webservice.dart` (all API endpoints, switching between dev `10.0.2.2:8080` and prod `rokamoka.inf.ufpel.edu.br` based on `kReleaseMode`)
- **`domain/`** — Business logic:
  - `providers/user_provider.dart` — `ChangeNotifier` that holds and persists `UserRole` via `SharedPreferences`
  - `services/` — One service class per domain area (auth, user, artwork, exposure, location, login, etc.), each making HTTP calls with a Bearer token from `AuthService`
- **`presentation/`**
  - `pages/` — Full screens
  - `widgets/` — Reusable UI components
  - `controllers/home_controller.dart` — Main shell managing the bottom navigation and modal page stack after login
  - `assets/` — Images and icons (all must be declared in `pubspec.yaml` under `flutter.assets`)

**State management**: `provider` package. `UserProvider` is provided at the root via `ChangeNotifierProvider`.

**Authentication**: `AuthService` uses `flutter_secure_storage` to persist the JWT token and user credentials. `UserProvider` uses `SharedPreferences` for role persistence.

**Navigation**: Named routes defined in `constants/routes.dart` and registered in `main.dart`. Deep links handled via `app_links` — links to `rokamoka-mobile.inf.ufpel.edu.br` with a `token` query param redirect to the forgot-password flow. Some screens (e.g. `EmblemArtworksScreen`) are pushed with `Navigator.push(MaterialPageRoute(...))` directly instead of named routes — this is intentional when argument typing is needed.

## User Roles and Navigation

`UserRole` enum: `anon`, `comum`, `administrador`, `curador`, `pesquisador`

The bottom navigation bar adapts per role:
- `anon`/`comum`: 5th tab shows "Solicitar Cargo" (leads to permission request)
- `administrador`: "Mais" menu with Permissões + Inserir Exposição + Locais
- `curador`: "Mais" menu with Permissões
- `pesquisador`: "Mais" menu with Inserir Exposição only

`HomeController` manages switching between the 4 main pages (Profile, QR, Collections, Emblems) and modal pages (CreateExposure, Permissions, Locations) without pushing to the navigator stack.

**Token staleness**: On startup, `main.dart` compares the role from `/user/me` against the `scope` claim decoded from the stored JWT. If the server role is privileged and the token scope doesn't match, the token is cleared and the user is sent back to login. This handles the case where a role upgrade happened but the old JWT was never replaced.

## API Integration

All endpoints are in `lib/constants/webservice.dart`. Services attach the Bearer token from `AuthService.getToken()` to every request using `HttpHeaders.authorizationHeader`.

**OBRIGATÓRIO**: Antes de adicionar ou modificar qualquer endpoint no app, consulte o contrato da API no Swagger. Nunca assuma um path, método ou DTO — sempre verifique.

### API response envelope

Every response follows the same envelope shape — always extract via `data['body']`, never assume the root is the payload:

```dart
final data = jsonDecode(response.body);
if (response.statusCode == 200) {
  return data['body'] as Map<String, dynamic>;
} else {
  throw Exception(data['exceptionMessage'] ?? data['error'] ?? 'Erro ${response.statusCode}');
}
```

For typed HTTP-error semantics (e.g. 403 = not yet earned), declare a custom exception class and throw it in the service; the screen catches it and renders a dedicated state. See `EmblemForbiddenException` in `emblem_service.dart` as the reference pattern.

### Artwork images

Images are stored and transmitted as **base64-encoded strings** in the `image` field of artwork objects. Decode with `base64Decode(image)` and display with `Image.memory(bytes)`. An empty `image` string means no image is available.

### Como consultar endpoints no Swagger

**ATENÇÃO — autenticação:** o `/v3/api-docs` e o `/swagger-ui` agora exigem **Bearer token**
(respondem `401` sem ele). Obtenha um token criando um usuário anônimo (não requer auth) e
use-o no header `Authorization: Bearer <token>` em todas as chamadas curl:

```bash
# Gerar token de um usuário anônimo
TOKEN=$(curl -s -X POST http://localhost:8080/user/anonymous/create \
  -H "Content-Type: application/json" -d '{"userName":"swagger_probe"}' \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['body']['jwt'])")
```

**Opção 1 — curl no terminal (use sempre que precisar verificar a API):**

```bash
# Listar todos os endpoints (método, path, tag, resumo)
curl -s http://localhost:8080/v3/api-docs -H "Authorization: Bearer $TOKEN" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for path, methods in sorted(data['paths'].items()):
    for method, info in methods.items():
        tags = info.get('tags', [])
        summary = info.get('summary', '')
        print(f\"{method.upper()} {path} [{', '.join(tags)}] - {summary}\")
"

# Ver detalhes completos de um endpoint específico (schemas, parâmetros, respostas)
curl -s http://localhost:8080/v3/api-docs -H "Authorization: Bearer $TOKEN" | python3 -c "
import json, sys
data = json.load(sys.stdin)
path = '/artwork/{exhibitionId}'   # <-- alterar conforme necessário
method = 'post'                    # <-- alterar conforme necessário
info = data['paths'][path][method]
print(json.dumps(info, indent=2, ensure_ascii=False))
"

# Resolver um schema DTO (ex: ArtworkInputDTO)
curl -s http://localhost:8080/v3/api-docs -H "Authorization: Bearer $TOKEN" | python3 -c "
import json, sys
data = json.load(sys.stdin)
schema_name = 'ArtworkInputDTO'    # <-- alterar conforme necessário
print(json.dumps(data['components']['schemas'][schema_name], indent=2, ensure_ascii=False))
"
```

**Opção 2 — Interface gráfica:** `http://localhost:8080/swagger-ui/index.html#/`

**O que verificar antes de implementar qualquer endpoint:**
1. Método HTTP correto (GET/POST/PATCH/DELETE)
2. Path exato (incluindo path params como `{id}`)
3. Query params obrigatórios/opcionais
4. Request body: schema DTO e campos `required`
5. Content-type: `application/json` vs `multipart/form-data`
6. Resposta esperada: shape do DTO de retorno e wrapping (`ApiResponseWrapper*`)
7. Autenticação: se requer Bearer token (a maioria requer)

### Endpoints disponíveis (gerado de http://localhost:8080/v3/api-docs)

| Método | Path | Tag | Descrição |
|--------|------|-----|-----------|
| PATCH | /artwork | Obra | Atualizar uma obra |
| GET | /artwork/exposicao/{exhibitionId} | Obra | Buscar obras por ID da exposição |
| GET | /artwork/qrcode/{qrcode} | Obra | Buscar obra por QR Code |
| POST | /artwork/upload/{artworkId} | Obra | Upload de uma imagem em uma obra |
| POST | /artwork/{exhibitionId} | Obra | Cadastrar uma nova obra |
| DELETE | /artwork/{id} | Obra | Remover uma obra |
| GET | /artwork/{id} | Obra | Buscar obra por ID |
| POST | /auth/forgot-password/reset | Autenticação | Redefinição de senha via token |
| POST | /auth/forgot-password/send | Autenticação | Disparo de email para redefinição |
| GET | /auth/login | Autenticação | Login de usuário |
| POST | /auth/reset-password | Autenticação | Redefinição de senha |
| GET | /emblems | Emblema | Listar emblemas por exposição (query `exhibitionId`) — sem constante em `webservice.dart` ainda |
| POST | /emblems/create | Emblema | Criar novo emblema |
| DELETE | /emblems/{id} | Emblema | Deletar emblema |
| GET | /emblems/{id} | Emblema | Buscar emblema por ID (retorna `artworks`; 403 se o usuário não conquistou o emblema) |
| POST | /evaluation/permission/accept/{permissionId} | Solicitação de Permissão | Aceitar permissão |
| POST | /evaluation/permission/deny/{permissionId} | Solicitação de Permissão | Rejeitar permissão |
| GET | /evaluation/permission/list | Solicitação de Permissão | Listar solicitações |
| PATCH | /exhibition | Exposição | Atualizar uma exposição |
| POST | /exhibition | Exposição | Cadastrar uma nova exposição |
| POST | /exhibition/add/artwork/{id} | Exposição | Adicionar obras a uma exposição |
| GET | /exhibition/all | Exposição | Listar todas as exposições |
| DELETE | /exhibition/{id} | Exposição | Remover uma exposição |
| GET | /exhibition/{id} | Exposição | Buscar exposição por ID |
| PATCH | /location | Local | Atualizar local existente |
| POST | /location | Local | Cadastrar novo local |
| GET | /location/address/all | Local | Buscar todos os endereços |
| GET | /location/address/{addressId} | Local | Buscar todos os locais de um endereço |
| GET | /location/all | Local | Buscar todos os locais |
| DELETE | /location/{id} | Local | Remover local existente |
| GET | /location/{id} | Local | Buscar local por id |
| POST | /mokadex/collect/{qrcode} | Mokadex | Adicionar obras/estrelas ao mokadex |
| GET | /mokadex/missing/{exhibitionId} | Mokadex | Obras/estrelas não coletadas |
| GET | /mokadex/summary | Mokadex | Obter resumo do Mokadex |
| POST | /request/permission/curator | Solicitação de Acesso | Solicitar acesso como curador |
| GET | /request/permission/me/status | Solicitação de Acesso | Status das solicitações do usuário |
| POST | /request/permission/researcher | Solicitação de Acesso | Solicitar acesso como Pesquisador |
| POST | /researcher/create | Pesquisador | Criação de pesquisador |
| POST | /user/anonymous/create | Usuário | Criação de usuário anônimo |
| GET | /user/me | Usuário | Visualizar dados do usuário |
| POST | /user/normal/create | Usuário | Criação de usuário "normal" |

### Emblem data from /user/me

Emblem data is nested inside the mokadex object, not a top-level field:

```
data['body']['mokaDex']['emblemSet']  →  List of conquered emblems
```

Each emblem entry has `id`, `nome`, `descricao`, and an `exhibition` map (`name`, `description`, `location`). The full artwork list for a conquered emblem is fetched separately via `GET /emblems/{id}`, which returns `artworks` in the response body.

## Dev tooling

**`device_preview`** is enabled in all non-release builds (`!kReleaseMode`). It wraps the entire widget tree, which affects layout measurements and `MediaQuery`. When debugging layout issues, be aware that the preview frame adds its own constraints.

## Tests

Tests live under `test/`:
- `test/domain/validators/` — unit tests for validators
- `test/presentation/` — widget tests for screens (e.g. `emblem_artworks_screen_test.dart`)

Widget tests that depend on `EmblemService` can inject a mock via the optional `emblemService` constructor parameter on `EmblemArtworksScreen`.

## Code Conventions

- File names: `snake_case.dart`
- Classes and enums: `PascalCase`
- Methods, variables, providers: `camelCase`
- Reusable components → `lib/presentation/widgets/`
- Full screens → `lib/presentation/pages/`
- New images/icons must be registered in `pubspec.yaml` under `flutter.assets` before use
- Commit prefixes follow: `feat:`, `fix:`, `build:`, `style:`, `refactor:`
