zle -N clear-ls
autoload clear-ls

function clear-ls() {
  clear
  ls -F .

  git status 2> /dev/null > /dev/null
  if [ $? -eq 0 ]; then
    git status -s
  fi

  echo
  zle reset-prompt
}
