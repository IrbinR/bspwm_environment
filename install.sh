#!/bin/bash

install_node() {
  # Instalar fnm (Fast Node Manager)
  curl -fsSL https://fnm.vercel.app/install | bash

  # activar fnm
  source "$HOME/.zshrc"

  # Obtener la última versión LTS de Nodejs
  fnm install --lts
}

install_git() {
  sudo pacman -S git --noconfirm
}

installer_package() {
  condition=$1
  package=$2
  if [[ $condition == "git" && $package == "node" ]]; then
    nodeConditon=$(! pacman -Q "$package" &>/dev/null || ! pacman -Q "nodejs" &>/dev/null || ! command -v "$package" &>/dev/null || ! command -v "nodejs" &>/dev/null)
    if ! pacman -Q "$condition" &>/dev/null && "$nodeConditon"; then
      install_git
      install_node
    elif ! pacman -Q "$1"; then
      install_git
    elif "$nodeConditon"; then
	    install_node
    fi
  elif [[ $condition == "1" ]]; then
    if ! pacman -Q "$package"; then
      if [[ $package == "broot" ]]; then
        broot_installer
      else
        sudo pacman -S "$package" --noconfirm
      fi
    fi
  elif [[ $condition == "2" ]]; then
    if ! yay -Q "$package"; then
      yay -S "$package" --noconfirm
    fi
  fi
}

verification_user-dirs() {
  source "$HOME"/.config/user-dirs.dirs
  if [[ -z "$XDG_DOWNLOAD_DIR" ]]; then
    echo "No existe el archivo user-dirs.dirs."
    exit 1
  fi

}

github() {
  option=$1
  repo=$2
  path="$XDG_DOWNLOAD_DIR/githubInstaller"
  if [[ $option -eq 1 ]]; then
    git clone "$repo" "$path"
  else
    rm -rf "$path"
  fi
}

mpd_path() {
  source "$HOME"/.config/user-dirs.dirs

  if [[ -z "$XDG_MUSIC_DIR" ]]; then
    echo "Error: La variable XDG_MUSIC_DIR no está definida."
    exit 1
  fi

  MPD_CONFIG="$HOME/.config/mpd/mpd.conf"

  sed -i "s|^music_directory.*|music_directory  \"$XDG_MUSIC_DIR\"|" "$MPD_CONFIG"
}

ncmpcpp_path() {
  source "$HOME"/.config/user-dirs.dirs

  NCMPCPP_CONFIG="$HOME/.config/ncmpcpp/config"

  sed -i "s|mpd_music_dir.*|mpd_music_dir = \"$XDG_MUSIC_DIR\"|" "$NCMPCPP_CONFIG"
}

rofi_theme() {
  source $HOME/.config/user-dirs.dirs
  PATH_ROFI=$XDG_DOWNLOAD_DIR/githubInstaller
  github 1 $1
  chmod +x "$PATH_ROFI/setup.sh"
  sed -i "s|DIR=\`pwd\`|DIR='$PATH_ROFI'|" "$PATH_ROFI/setup.sh"
  github 2
}

lazyvim_installer() {
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  # MENSAJE
}

bat_config() {

  # Archivo de configuración
  ZSHRC_FILE="$HOME/.zshrc"

  # Comprobar si los aliases ya están presentes
  if ! grep -E -q "^# \|\s+ALIAS BAT\s+\|$" "$ZSHRC_FILE"; then
    cat <<EOL >>"$ZSHRC_FILE"

# ====================================================
# |                      ALIAS BAT                   |
# ====================================================
alias cat='bat'
EOL

    mkdir -p "$(bat --config-dir)/themes"
    wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
    bat cache --build
    path_bat=$HOME/.config/bat/config
    cat <<EOF >"$path_bat"
--theme="Catppuccin Macchiato"
EOF
  fi
}

broot_installer() {
  sudo pacman -S broot --noconfirm
  echo -e "y\n" | broot
  source $HOME/.zshrc
  ZSHRC_FILE="$HOME/.zshrc"

  if ! grep -E "^# \|\s+BROOT\s+\|$" "$ZSHRC_FILE"; then
    cat <<EOL >>"$ZSHRC_FILE"

# ====================================================
# |                     BROOT                        |
# ====================================================
source $HOME/.zshrc
alias tree='br'
EOL
  fi
}

lsd_config() {
  ZSHRC_FILE="$HOME/.bashrc"

  # Comprobar si los aliases ya están presentes
  if ! grep -E -q "^# \|\s+ALIAS LSD\s+\|$" "$ZSHRC_FILE"; then
    cat <<EOL >>"$ZSHRC_FILE"

# ====================================================
# |                      ALIAS LSD                   |
# ====================================================
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
EOL
  fi
}

zsh_installer() {

  mkdir -p "$LOGDIR"
  LOGFILE="$LOGDIR/zsh_install.log"

  #Leer el último estado guardado
  if [[ -f $LOGFILE ]]; then
    LAST_STEP=$(tail -n 1 $LOGFILE)
  else
    LAST_STEP=0
  fi

  # Paso 1: Instalar Zsh
  if [[ "$LAST_STEP" -lt 1 ]]; then
    sudo pacman -S zsh --noconfirm
    cat <<EOF >$LOGFILE
  1
EOF
  fi

  # Paso 2: Cambiar la shell por defecto
  if [[ "$LAST_STEP" -lt 2 ]]; then
    sudo usermod --shell /usr/bin/zsh root
    sudo usermod --shell /usr/bin/zsh $USER
    if [[ ! -f "$HOME/.zshrc" ]]; then
      cat <<EOF >"$HOME/.zshrc"
  # Zsh configuration file created automatically
EOF
    fi
    cat <<EOF >>$LOGFILE
  2
EOF

    cat <<EOF
  ===============================================================
  | 	       Instrucción después de cerrar sesión		            |
  ===============================================================
  Se cerrara sesión, vuelva a ingresar, después ejecute nuevamente
  este mismo script para continuar con la instalación.

  ===============================================================
EOF
    read -p "Presione ENTER para cerrar sesión "
    kill -9 -1
  fi

  # Paso 3: Terminar configuracion
  if [[ "$LAST_STEP" -lt 3 ]]; then
    cat <<EOF
  ===============================================================
  |              CONTINUANDO CON LA INSTALACION                 |
  ===============================================================
EOF
    zimfw_cmd="curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh"
    if pacman -Q curl; then
      eval "$zimfw_cmd"
    else
      sudo pacman -S curl --noconfirm
      eval "$zimfw_cmd"
    fi

    cat <<EOF >>$LOGFILE
  3
EOF
  fi

  if [[ "$LAST_STEP" -lt 4 ]]; then
    path="$HOME/.zimrc"
    sed -i "s|zmodule asciiship|#zmodule asciiship|" "$path"

    source $HOME/.config/user-dirs.dirs
    sudo pacman -S starship --noconfirm
    cat <<EOF >>"$HOME/.zshrc"
  # ====================================================
  # |                      STARSHIP                    |
  # ====================================================
  eval "\$(starship init zsh)"
EOF
  fi

}

fonts_installer() {
  path_fonts=$(pwd)/assets/fonts
  directory1="/usr/share/fonts/OTF/"
  directory2="/usr/share/fonts/TTF/"
  if [[ ! -d "$directory1" ]]; then
    sudo mkdir "$directory1"
  fi
  sudo cp -r "$path_fonts/OTF" "$directory1"

  if [[ ! -d "$directory2" ]]; then
    sudo mkdir "$directory2"
  fi
  sudo cp -r "$path_fonts/TTF" "$directory2"
  sudo fc-cache -f -v
}

music_installer() {
  source $HOME/.config/user-dirs.dirs
  path_music=$(pwd)/assets/music
  cp -r "$path_music/"* "$XDG_MUSIC_DIR"
}

wallpaper_installer() {
  source $HOME/.config/user-dirs.dirs
  path_wallpaper=$(pwd)/assets/wallpaper
  cp -r "$path_wallpaper" "$XDG_PICTURES_DIR"
}

verification_user-dirs

#Usar un directorio en el hogar para almacenar el log
LOGDIR="$HOME/.local/share/my_temp_scripts"

zsh_installer

sudo pacman -S unzip --needed --noconfirm

fonts_installer

music_installer

wallpaper_installer

repositorios=(https://aur.archlinux.org/yay.git "curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh" "https://github.com/adi1090x/rofi.git")

pacman_package=("git node" "1 bspwm" "1 rofi" "1 dunst" "1 kitty" "1 mpd" "1 ncmpcpp" "1 neofetch" "1 feh" "1 neovim" "1 pcmanfm" "1 picom" "1 polybar" "1 yazi" "1 htop" "1 lsd" "1 bat" "1 scrot" "1 xautolock")

for package in "${pacman_package[@]}"; do
  read -r arg1 arg2 <<<"$package"
  installer_package "$arg1" "$arg2"
done

pathFolder=$(pwd)/config
appConfig=(bspwm dunst kitty mpd ncmpcpp neofetch picom polybar rofi nvim bat lsd)

for app in "${appConfig[@]}"; do
  if [[ ! $app == "rofi" && ! $app == "bat" && ! $app == "lsd" ]]; then
    cp -rf "$pathFolder/$app" "$HOME/.config/"
  fi

  if [[ $app == "mpd" ]]; then
    mpd_path
  elif [[ $app == "ncmpcpp" ]]; then
    ncmpcpp_path
  elif [[ $app == "rofi" ]]; then
    rofi_theme "${repositorios[2]}"
  elif [[ $app == "nvim" ]]; then
    lazyvim_installer
  elif [[ $app == "bat" ]]; then
    bat_config
  elif [[ $app == "lsd" ]]; then
    lsd_config
  fi

done

yay_package="2 betterlockscreen"

# INSTALACION YAY
sudo pacman -S base-devel --noconfirm --needed
github 1 "${repositorios[0]}"
cd $XDG_DOWNLOAD_DIR/githubInstaller && makepkg -sri
cd
github 2

installer_package "$yay_package"
cp -rf "$pathFolder" "$HOME/.config/"

cat <<EOF

===============================================================
|                   INSTALACION COMPLETADA	                  |
===============================================================
Ejecute en una nueva terminal el siguiente comando para tener 
toda la instalación completada:
# zimfw uninstall
EOF
rm -rf "$LOGDIR"
