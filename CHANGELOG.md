# Histórico de mudanças

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/), e as versões
seguem o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## 1.1.1 - 2026-10-25

### Corrigido

- **Tela de bloqueio sem o tema:** a User Themes é desativada quando a tela bloqueia, e o Shell
  voltava ao tema padrão. Por isso o visual da tela de bloqueio da 1.1.0 nunca aparecia. A nova
  extensão `winxpremix-lockscreen@winxpremix`, instalada pelo `install.sh`, mantém o tema
  WinXPRemix enquanto a tela está bloqueada. É preciso sair e entrar de novo uma vez.
- **Detalhes da tela de bloqueio:**
  - aparecia um segundo painel azul em volta do campo de senha;
  - o avatar ficava num quadrado com a imagem redonda dentro e agora é redondo, com moldura branca;
  - o campo de senha agora é branco também no modo escuro.
- **GTK3:** o botão selecionado na barra de título (como as abas do widget factory) ficava com
  texto branco sobre fundo branco, e o hover deixava um contorno laranja dentro da barra azul.

### Mudado

- Capturas de tela refeitas, com imagens novas da tela de bloqueio, da visão geral, do
  diálogo de alerta e dos grupos de alternância.

## 1.1.0 - 2026-10-25

### Adicionado

- **Tela de bloqueio "Bem-vindo":** o relógio e o campo de senha ficam num painel azul Luna, o
  avatar ganha moldura branca, o campo de senha fica branco, os botões seguem o estilo XP e as
  notificações viram balões amarelos.
- **Mais widgets GTK4/libadwaita:**
  - diálogos de alerta com faixa azul no topo e moldura;
  - aba ativa com a cor do conteúdo e hover laranja;
  - grupos de alternância com o item ativo em azul;
  - botões planos com borda no hover (branca translúcida na barra de título);
  - botões `.osd` no azul do OSD do Shell.
- **Flatpak:** o `install.sh` libera `~/.config/gtk-4.0` para apps Flatpak
  (`--no-flatpak` desliga). O `uninstall.sh` desfaz só o que o install criou e mantém os
  outros overrides.
- Arquivo `VERSION`, que o build grava no `index.theme`.

### Mudado

- **Paleta única:** `src/_palette.scss` é a única fonte de cores. O build gera as variáveis `--xp-*`
  do GTK4 a partir dela (`src/gtk-4.0/palette.scss`), e o GTK3 passou a usar a paleta
  para a barra de progresso, os sliders e as caixas de check.
- **Modo escuro:** a barra de título do GTK3 e os diálogos do Shell usam o mesmo azul um pouco mais
  fechado que o GTK4 já usava.

### Corrigido

- **Headerbars desalinhadas no libadwaita 1.9:** quando a barra de título vinha empilhada com outra barra
  (como a busca do Arquivos e das Configurações), apareciam faixas escuras de 3px e a barra
  ficava mais baixa que a do outro painel.
- `./install.sh --help` imprimia a linha `set -euo pipefail` junto com a ajuda.

## 1.0.0 - 2026-10-25

Primeira versão:
- tema do GNOME Shell 50+ (barra de tarefas Luna, botão Iniciar, área de notificação, menus,
  configurações rápidas, balões de notificação, Alt+Tab, OSD, dash);
- GTK3;
- override do libadwaita;
- papéis de parede "Colina" dia/noite;
- troca automática claro/escuro;
- scripts de instalação e remoção.
