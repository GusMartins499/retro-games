# retro-games

Configuração e saves dos meus emuladores (PS1, SNES e N64) no Linux, para
reinstalar tudo depois de formatar o PC.

- **ES-DE**: o menu, que lista os jogos e abre o emulador certo.
- **RetroArch** (Flatpak) com os cores PCSX ReARMed / Beetle PSX HW (PS1),
  Snes9x (SNES) e Mupen64Plus-Next (N64).

As ROMs e BIOS **não** ficam aqui.

## Instalar

```sh
git clone https://github.com/GusMartins499/retro-games.git ~/www/retro-games
~/www/retro-games/install.sh
```

Depois copie as ROMs para `~/ROMs/{psx,snes,n64}` e abra o **ES-DE** pelo menu
de aplicativos.

O script pode ser rodado de novo sem problema: ele pula o que já está instalado.

## O que fica no repositório

| Pasta | Conteúdo |
|---|---|
| `saves/` | saves dos jogos e memory cards do PS1, separados por core |
| `states/` | save states do RetroArch |
| `es-de/settings/` | configurações do ES-DE |
| `es-de/gamelists/` | escolha de emulador por sistema, favoritos e tempo de jogo |

O `install.sh` aponta o RetroArch para `saves/` e `states/` e cria links de
`~/ES-DE/settings` e `~/ES-DE/gamelists` para `es-de/`.

## Backup dos saves

```sh
~/www/retro-games/backup.sh
```

Faz commit e push de tudo que mudou em `saves/`, `states/` e `es-de/`.

## ROMs

- PS1: `.cue` + `.bin`, `.chd` ou `.pbp`, nunca `.rar` ou `.zip`. Para um jogo
  com vários `.bin` aparecer uma vez só no ES-DE, coloque os arquivos numa pasta
  com o nome do `.cue`, por exemplo:
  `psx/Road Rash (USA).cue/Road Rash (USA).cue` e `.../Road Rash (USA).bin`.
- SNES: `.sfc`, `.smc` ou `.zip`.
- N64: `.z64`, `.n64`, `.v64` ou `.zip`.

## PS1 e BIOS

O PS1 usa o **PCSX ReARMed**, que funciona sem BIOS. Com uma BIOS
(`scph5501.bin`) em `~/.var/app/org.libretro.RetroArch/config/retroarch/system/`,
dá para trocar para o **Beetle PSX HW** no ES-DE (*Other settings → Alternative
emulators*), que tem compatibilidade melhor.

O memory card 1 é criado sozinho por jogo (`saves/PCSX-ReARMed/<jogo>.srm`) e o
card 2 é compartilhado (`saves/PCSX-ReARMed/pcsx-card2.mcd`).
