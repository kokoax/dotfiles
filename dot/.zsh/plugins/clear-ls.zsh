zle -N clear-ls
autoload clear-ls

function clear-ls() {
  clear
  ls . # eza v0.23.0周辺のバグらしい、治ってたら . を消しても良い

  git status 2> /dev/null > /dev/null
  if [ $? -eq 0 ]; then
    git status -s
  fi

  echo
  zle reset-prompt
}
