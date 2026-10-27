# Tarefa: pipeline de build iOS sem Mac (Flutter → .ipa sem assinatura para sideload)

## Contexto

- App Flutter/Dart. Eu desenvolvo no **Fedora Linux** e **não tenho Mac**.
- Objetivo: gerar um `.ipa` **sem assinatura** em um runner macOS na nuvem, para que um colega do grupo instale no **iPhone 13** dele via sideload (Sideloadly / Sideloader / SideStore) usando um **Apple ID gratuito**.
- Não vamos usar Apple Developer Program pago por enquanto. Portanto, nada de TestFlight, Ad Hoc ou assinatura no CI.
- Limitações aceitas: o app expira em 7 dias, cabem no máximo 3 apps por Apple ID, e não há push notifications (APNs).

## O que preciso que você faça

### 1. Auditar o projeto iOS
Verifique e me reporte, corrigindo o que for seguro corrigir:
- [ ] `PRODUCT_BUNDLE_IDENTIFIER` em `ios/Runner.xcodeproj/project.pbxproj`. Se for `com.example.*`, proponha um id único (ex.: `br.ufpel.<nomedoapp>`) e me pergunte antes de trocar. Se o app usa Firebase, o id precisa bater com o app iOS registrado no console Firebase.
- [ ] `ios/Runner/Info.plist`: liste os plugins do `pubspec.yaml` que exigem chaves de permissão (`NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSMicrophoneUsageDescription` etc.) e adicione as que faltarem, com texto em português.
- [ ] `ios/Podfile`: a linha `platform :ios, 'X'` deve ser compatível com a versão mínima exigida pelos plugins. Use pelo menos a mínima atual do Flutter estável.
- [ ] Ícone do app (`ios/Runner/Assets.xcassets/AppIcon.appiconset`): verifique se existe e se não tem canal alpha.
- [ ] **Firebase**: verifique se existe `ios/Runner/GoogleService-Info.plist` e se ele está no `.gitignore`. Se o app depende dele e o arquivo não está versionado, o CI precisa recebê-lo via secret (passo 2).
- [ ] Verifique se há código que depende de push (firebase_messaging). Ele não deve quebrar o app quando não houver permissão ou token APNs.

### 2. Criar o workflow do GitHub Actions
Crie `.github/workflows/ios-unsigned.yml`:
- Disparo: `workflow_dispatch` (manual). Opcionalmente, também em push de tag `v*`.
- `runs-on: macos-latest`.
- Usar `subosito/flutter-action@v2`, fixando a **mesma versão do Flutter** que uso localmente (confira com `flutter --version` ou `.fvmrc` se existir; se não achar, me pergunte).
- Cache de pub e de CocoaPods.
- Se existir secret `GOOGLE_SERVICE_INFO_PLIST` (conteúdo em base64), decodificar para `ios/Runner/GoogleService-Info.plist` antes do build.
- Passos de build:
  ```bash
  flutter pub get
  flutter build ios --release --no-codesign
  mkdir -p Payload
  cp -r build/ios/iphoneos/Runner.app Payload/
  zip -qr app-unsigned.ipa Payload
  ```
- Publicar `app-unsigned.ipa` com `actions/upload-artifact@v4`, com nome incluindo a versão do `pubspec.yaml` e o número do run.
- Se o build falhar, o log precisa mostrar claramente o erro do Xcode/CocoaPods. Não esconda a saída.

> Observação: em repositório **privado** os minutos de macOS do GitHub acabam rápido. Me diga se o repo é público ou privado. Se for privado, faça também o passo 3.

### 3. (Alternativa) `codemagic.yaml`
Crie um `codemagic.yaml` equivalente, para usar no plano gratuito do Codemagic (500 min/mês em macOS M2, conta pessoal):
- Workflow `ios-unsigned`, `instance_type: mac_mini_m2`, mesma versão do Flutter.
- Mesmos passos de build e empacotamento em `Payload/`.
- `artifacts: - app-unsigned.ipa`.
- Variável de ambiente para o `GoogleService-Info.plist` em base64, se necessário.
- Sem assinatura, sem publicação.

### 4. Documentação para o grupo
Crie `docs/INSTALAR-NO-IPHONE.md`, em português e para alguém não técnico, com:
1. **Como baixar o `.ipa`** (link para a aba Actions / artefatos do Codemagic).
2. **Opção A: tem PC Windows/Mac:** instalar com **Sideloadly** (cabo USB, "Confiar neste computador", arrastar o `.ipa`, entrar com o Apple ID; o código de 2 fatores chega no iPhone).
3. **Opção B: sem computador:** visita única ao meu PC (Fedora) para instalar o **SideStore** via **Sideloader** (`sudo dnf install usbmuxd`; `sideloader install SideStore.ipa -i`; gerar arquivo de pareamento). Depois disso, instalar e renovar o `.ipa` pelo próprio iPhone.
4. **No iPhone:** Ajustes → Privacidade e Segurança → **Modo de Desenvolvedor** (reinicia e pede confirmação); Ajustes → Geral → **VPN e Gerenciamento de Dispositivos** → Confiar no Apple ID.
5. **Limites:** expira em 7 dias, máximo de 3 apps por Apple ID, sem notificações push. Cada nova versão do app precisa ser reinstalada.
6. **Problemas comuns:** app fecha ao abrir (provável permissão faltando no Info.plist), "Desenvolvedor não confiável", "Maximum number of apps", 2FA.

### 5. README
Adicione ao `README.md` uma seção curta "Build iOS" apontando para o workflow e para `docs/INSTALAR-NO-IPHONE.md`.

## Restrições
- Não adicione assinatura de código, certificados, perfis de provisionamento nem fastlane match. Fica fora do escopo.
- Não faça commit de segredos (`GoogleService-Info.plist`, chaves). Use secrets.
- Não altere a lógica do app além do necessário para compilar e rodar no iOS.
- Antes de mudanças grandes no projeto iOS (bundle id, Podfile, deployment target), me mostre o diff e peça confirmação.

## Entregáveis
1. Relatório da auditoria do passo 1 (o que estava ok, o que foi corrigido, o que precisa de decisão minha).
2. `.github/workflows/ios-unsigned.yml`
3. `codemagic.yaml` (se o repo for privado, ou se eu pedir)
4. `docs/INSTALAR-NO-IPHONE.md`
5. Seção no `README.md`
