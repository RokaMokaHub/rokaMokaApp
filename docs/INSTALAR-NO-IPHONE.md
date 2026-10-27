# Como instalar o Roká Móka no iPhone

Este guia explica como instalar o app no iPhone **sem App Store**, usando um Apple ID gratuito.
Não é preciso ser programador: basta seguir os passos na ordem.

---

## 1. Baixar o arquivo do app (`.ipa`)

1. Acesse a aba **Actions** do repositório:
   https://github.com/RokaMokaHub/rokaMokaApp/actions/workflows/ios-unsigned.yml
2. Clique na execução mais recente com o ícone verde (✔).
3. Role até o final da página, na seção **Artifacts**, e clique em `rokamoka-ios-unsigned-...`.
   É preciso estar logado no GitHub para baixar.
4. O download vem em `.zip`. Descompacte e você terá o arquivo **`app-unsigned.ipa`**.

> Não achou nenhuma execução? Peça para quem cuida do projeto clicar em **Run workflow** nessa página.

---

## 2. Opção A — você tem um computador Windows ou Mac

Use o programa **Sideloadly** (gratuito): https://sideloadly.io

1. Instale o Sideloadly no computador. No Windows, instale também o **iTunes** e o **iCloud**
   baixados do site da Apple (não da Microsoft Store).
2. Ligue o iPhone no computador com o **cabo USB**.
3. No iPhone, toque em **"Confiar neste computador"** e digite o código do iPhone.
4. Abra o Sideloadly. O iPhone deve aparecer no campo de dispositivo.
5. **Arraste o arquivo `app-unsigned.ipa`** para a janela do Sideloadly.
6. No campo **Apple ID**, digite o seu e-mail da Apple e clique em **Start**.
7. Digite a senha do Apple ID quando pedir.
8. Se pedir **código de verificação (2 fatores)**, ele chega **no próprio iPhone**. Digite-o no Sideloadly.
9. Aguarde até aparecer **"Done"**. O ícone do Roká Móka aparece na tela do iPhone.

Depois siga para o passo **4 (No iPhone)**.

---

## 3. Opção B — você não tem computador

Você vai precisar ir **uma única vez** ao computador (Fedora Linux) de quem cuida do projeto,
para instalar o **SideStore**. Depois disso, tudo é feito pelo próprio iPhone.

### No computador Fedora (feito por quem cuida do projeto)

```bash
# 1. Serviço que conversa com o iPhone pelo USB
sudo dnf install usbmuxd
sudo systemctl start usbmuxd

# 2. Baixe o Sideloader (https://github.com/Dadoum/Sideloader/releases)
#    e o SideStore.ipa (https://sidestore.io)

# 3. Com o iPhone conectado no cabo e "Confiar neste computador" aceito:
sideloader install SideStore.ipa -i
```

4. Gere o **arquivo de pareamento** do iPhone (seguir o guia oficial do SideStore em
   https://docs.sidestore.io — seção *Pairing File*) e envie para o iPhone (AirDrop, e-mail, Drive).
5. Ative o **Modo de Desenvolvedor** no iPhone (passo 4 abaixo) e abra o SideStore uma vez para
   importar o arquivo de pareamento.

### Depois, no iPhone (sempre que quiser instalar ou renovar)

1. Baixe o `app-unsigned.ipa` no iPhone (pelo Safari, seguindo o passo 1).
2. Abra o **SideStore** → aba **My Apps** → botão **+** → escolha o `app-unsigned.ipa`.
3. Para renovar antes de expirar: SideStore → **My Apps** → **Refresh All**.

> O SideStore precisa de um app de VPN local (por exemplo **LocalDevVPN** ou **StosVPN**, conforme o
> guia do SideStore) ligado na hora de instalar ou renovar.

---

## 4. No iPhone (vale para as duas opções)

1. **Ativar o Modo de Desenvolvedor**
   Ajustes → **Privacidade e Segurança** → role até o fim → **Modo de Desenvolvedor** → ativar.
   O iPhone vai **reiniciar**. Depois de ligar, ele pergunta de novo: toque em **Ativar** e digite o código.
   (Se a opção não aparecer, instale o app primeiro pelo Sideloadly/SideStore e volte aqui.)
2. **Confiar no seu Apple ID**
   Ajustes → **Geral** → **VPN e Gerenciamento de Dispositivos** → toque no seu e-mail →
   **Confiar em "..."** → **Confiar**.
3. Abra o Roká Móka. 🎉

---

## 5. Limites (Apple ID gratuito)

- O app **expira em 7 dias**. Depois disso ele não abre mais: é só reinstalar (Opção A) ou
  tocar em **Refresh** no SideStore (Opção B). Seus dados de login podem ser perdidos ao reinstalar.
- No máximo **3 apps** instalados assim por Apple ID ao mesmo tempo (o SideStore conta como um).
- **Sem notificações push.**
- Cada **nova versão** do app precisa ser baixada e instalada de novo.

---

## 6. Problemas comuns

| Problema | O que fazer |
|---|---|
| O app **fecha sozinho logo ao abrir** | Provavelmente expirou (7 dias): reinstale. Se é a primeira instalação, avise quem cuida do projeto — pode faltar uma permissão no `Info.plist`. |
| **"Desenvolvedor não confiável"** / "Untrusted Developer" | Faça o passo 4.2 (Confiar no Apple ID). |
| **"Maximum number of apps"** / limite de apps | Apague outro app instalado por sideload ou use outro Apple ID. |
| Não chega o **código de 2 fatores** | O código aparece no iPhone/Mac ligado ao seu Apple ID. Se não aparecer: Ajustes → [seu nome] → **Iniciar Sessão e Segurança** → **Obter Código de Verificação**. |
| Sideloadly não encontra o iPhone | Troque o cabo/porta USB, desbloqueie o iPhone e aceite "Confiar neste computador". No Windows, confira se o iTunes do site da Apple está instalado. |
| "Modo de Desenvolvedor" não aparece | Instale o app uma vez (mesmo que não abra) e a opção passa a aparecer em Privacidade e Segurança. |
