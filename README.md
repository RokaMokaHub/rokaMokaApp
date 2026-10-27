# roka_moka_app

# ROKA MOKA - Aplicativo de Gamificação para Museus

## 📜 Descrição

#### O ROKA MOKA é um aplicativo desenvolvido para aumentar a interatividade e a imersão dos visitantes em exposições de museus da cidade de Pelotas. Utilizando o conceito de gamificação com educação, o app permite que o usuário escaneie QR codes de obras para ganhar estrelas, ler informações adicionais e desbloquear emblemas ao completar missões de exposições.

#### O aplicativo visa tornar a experiência cultural mais envolvente, promovendo aprendizado de forma divertida e dinâmica.

## 🎯 Objetivo

### - Usuário: Escanear QR codes em obras de arte em exposições.

### - Metas: Acumular estrelas por cada obra escaneada, desbloquear informações e, ao completar a coleção, ganhar emblemas.

### - Educação e Diversão: Mistura de aprendizado sobre as obras com desafios de gamificação para manter o interesse do visitante.

## 💻 Stack utilizada

**Flutter**: Framework cross-platform para desenvolvimento mobile, escolhido pela sua performance, facilidade de manutenção e pela capacidade de desenvolver para Android e iOS a partir de uma base de código única.

**Clean Architecture**: Padrão de arquitetura que garante uma separação clara de responsabilidades, tornando o código mais escalável, testável e modular.

**Firebase**: Utilizado para armazenamento em tempo real de dados do usuário e para gerenciar autenticação e notificações.

## 🔧 Como Rodar o Projeto Localmente

### Pré-requisitos

**-- Flutter instalado**

**-- Android Studio ou Visual Studio Code** com as extensões Flutter e Dart instaladas.

### Passos

**-- Clone o repositório:** https://github.com/RokaMokaHub/rokaMokaApp.git

**-- Instale as dependências:** cd roka-moka -- flutter pub get

## 🍎 Build iOS

Não é preciso Mac: o `.ipa` sem assinatura é gerado no GitHub Actions pelo workflow
[`.github/workflows/ios-unsigned.yml`](.github/workflows/ios-unsigned.yml)
(aba **Actions** → **iOS (sem assinatura)** → **Run workflow**, ou push de uma tag `v*`).

Para instalar no iPhone via sideload com Apple ID gratuito, veja
[`docs/INSTALAR-NO-IPHONE.md`](docs/INSTALAR-NO-IPHONE.md).
