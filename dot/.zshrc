# zmodload zsh/zprof && zprof

alias mm='nvim ~/memos/memo.md'
alias mfm='my_favorit_memos'

#一定時間で画面がOFFにならないようにする
# xset s off        #BlankTimeをoff
# xset dpms 0 0 0   #DPMSの機能をそれぞれoff

# コンソール透過(カーソルが触ってるwindowを透過するからよくない) # alacrittyなら本体についてる
# transset-df 0.8 -p 1> /dev/null

bindkey -e

# Created by newuser for 5.0.2
LANG=ja_JP.UTF-8

# neovim のinit.vimのフォルダを探すのに利用
export XDG_CONFIG_HOME=$HOME/.config

#コマンドを10000保存する
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000

# home binファイル をエクスポート
export PATH=$HOME/.bin:$PATH # 他の方の実行ファイル
export PATH=$HOME/.mybin:$PATH # 自分の実行ファイル
# local binファイル をエクスポート
export PATH=$HOME/.local/bin:$PATH # binをPATHに追加するのも忘れずに
# Homebrew
export PATH=/opt/homebrew/bin:$PATH

# iterm2を使っているとLC_*系が軒並み空になるのでとりあえずLC_CTYPEだけでも入れておく
export LC_CTYPE=$LANG

# キャッシュを使うことでパッケージマネージャのupdateを速くする
zstyle ':completion:*' use-cache true

#historyコマンドを共有しない
#setopt HIST_NO_STORE

#以下２つは同じコマンドを記録しないようにするオプション
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

#開始と終了を記録?
setopt HIST_EXPAND

#ビープ音を出さない
setopt nolistbeep

##色を使う
setopt prompt_subst

##補完候補一覧をファイル種別ごとに色を変える
setopt list_types

##補完機能の有効化
autoload -Uz compinit
compinit -u

#Tab補完を詰めて表示する
setopt list_packed

#auto_pushd cdで今まで移動したパスを補完する
setopt auto_pushd

##これを入れるとターミナル表示が適応される
unsetopt correct
set -0

#aliasを展開して補完
unsetopt complete_aliases

setopt auto_cd		#cdを入力しなくてもディレクトリを移動できる
setopt auto_pushd	#移動したディレクトリを記録する

#補完した候補を自動表示
autoload predict-on
predict-on

#historyとzhr_hisotoryの共有
setopt SHARE_HISTORY

autoload bashcompinit
bashcompinit

# プロンプトでもコメントアウトを有効化
setopt interactivecomments

# 補完を選択できるオプション？
#setopt menu_complete


# タブ補完で表示されるものの設定
# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%B%d%b'
# zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# zstyle ':completion:*' group-name ''

# [ -f ~/.bin/zen ] && ~/.bin/zen

# GoEnv
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source $HOME/.gvm/scripts/gvm
export PATH=$HOME/.ghq/bin:$GOPATH/bin:$PATH
export GOPATH=$HOME/.ghq
export GOMODCACHE=$HOME/.ghq/cache
export gowork=$GOPATH/src/github.com/kokoax

# export NVM_DIR="$HOME/.config"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# kiex(elixirのversion manager)の設定
export PATH=~/.kiex/bin:$PATH
[[ -s "$HOME/.kiex/scripts/kiex" ]] && source "$HOME/.kiex/scripts/kiex"

# anyenv
if [ -d $HOME/.anyenv ] ; then
  export PATH="$HOME/.anyenv/bin:$PATH"
  eval "$(anyenv init - --no-rehash)"
fi

# goenv
if [ -d $HOME/.anyenv/envs/goenv ] ; then
  export PATH=$HOME/.anyenv/envs/goenv/shims:$PATH
fi

export EDITOR=nvim
eval "$(direnv hook zsh)"

# ruby settings
export PATH=$(ruby -e 'print Gem.user_dir')/bin:$PATH

# roswell settings
export PATH=$HOME/.roswell/bin:$PATH
# rust settings
export PATH=$HOME/.cargo/bin:$PATH


# aws cliの補完を有効化
complete -C '/usr/local/bin/aws_completer' aws

# コマンドのオプション補完ファイルをfpathに追記
[ -e ~/.zsh/lib ] && export FPATH=$FPATH:$HOME/.zsh/lib

# 分割した.zshファイルを読み込み
[ -f ~/.zsh/zsh.brew ]	  && source ~/.zsh/zsh.brew
[ -f ~/.zsh/zsh.alias ]		&& source ~/.zsh/zsh.alias
[ -f ~/.zsh/zsh.keybind ]	&& source ~/.zsh/zsh.keybind
[ -f ~/.zsh/zsh.color ]		&& source ~/.zsh/zsh.color
[ -f ~/.cargo/env ]       && source "$HOME/.cargo/env"
[ -f ~/.zsh/zsh.plugins ]	&& source ~/.zsh/zsh.plugins

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi

IGNOREEOF=10   # Shell only exists after the 10th consecutive Ctrl-d
set -o ignoreeof  # Same as setting IGNOREEOF=10
export TERMINFO=/usr/share/terminfo

# /Users/ca01072/.zshrc:153: can't find terminal definition for tmux-256color

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/kokoax/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

source /opt/homebrew/opt/asdf/libexec/asdf.sh
source ~/.asdf/plugins/golang/set-env.zsh
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

for version in $(ls ~/.asdf/installs/golang); do
  export PATH=$PATH:~/.asdf/installs/golang/$version/bin
done

export PATH="${PATH}:${HOME}/Library/Android/sdk/emulator"
export PATH="${PATH}:${HOME}/Library/Android/sdk/platform-tools"

[ -z "$TMUX" ] && tmux -u
