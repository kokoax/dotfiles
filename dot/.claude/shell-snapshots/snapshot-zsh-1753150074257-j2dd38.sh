# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
asdf () {
	case $1 in
		("shell") if ! shift
			then
				printf '%s\n' 'asdf: Error: Failed to shift' >&2
				return 1
			fi
			eval "$(asdf export-shell-version sh "$@")" ;;
		(*) command asdf "$@" ;;
	esac
}
asdf_update_golang_env () {
	local go_bin_path
	go_bin_path="$(asdf which go 2>/dev/null)" 
	if [[ -n "${go_bin_path}" ]]
	then
		export GOROOT
		GOROOT="$(dirname "$(dirname "${go_bin_path:A}")")" 
		export GOPATH
		GOPATH="$(dirname "${GOROOT:A}")/packages" 
		export GOBIN
		GOBIN="$(dirname "${GOROOT:A}")/bin" 
	fi
}
backward-delete-char-incr () {
	correct-prediction
	remove-prediction
	if zle backward-delete-char
	then
		show-prediction
	fi
}
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
clear-ls () {
	clear
	eza --classify=auto -F
	git status 2> /dev/null > /dev/null
	if [ $? -eq 0 ]
	then
		git status -s
	fi
	echo
	zle reset-prompt
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
correct-prediction () {
	if ((now_predict == 1))
	then
		if [[ "$BUFFER" != "$buffer_prd" ]] || ((CURSOR != cursor_org))
		then
			now_predict=0 
		fi
	fi
}
delete-backward-and-predict () {
	if (( $#LBUFFER > 1 ))
	then
		setopt localoptions noshwordsplit noksharrays
		if [[ $LBUFFER = *$'\012'* || $LASTWIDGET != (self-insert|magic-space|backward-delete-char) ]]
		then
			zstyle -t ":predict" toggle && predict-off
			LBUFFER="$LBUFFER[1,-2]" 
		else
			((--CURSOR))
			zle .history-beginning-search-forward || RBUFFER="" 
			return 0
		fi
	else
		zle .kill-whole-line
	fi
}
delete-no-predict () {
	[[ $WIDGET != delete-char-or-list || -n $RBUFFER ]] && predict-off
	zle .$WIDGET "$@"
}
expand-or-complete-prefix-incr () {
	correct-prediction
	if ((now_predict == 1))
	then
		CURSOR="$cursor_prd" 
		now_predict=0 
		comppostfuncs=(limit-completion) 
		zle list-choices
	else
		remove-prediction
		zle expand-or-complete-prefix
	fi
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
history-with-fzf () {
	local BUFFER=`history -n 1 | grep "$1" | fzf --exact --no-sort --tac` 
}
insert-and-predict () {
	setopt localoptions noshwordsplit noksharrays
	if [[ $LBUFFER == *$'\012'* ]] || (( PENDING ))
	then
		zstyle -t ":predict" toggle && predict-off
		zle .$WIDGET "$@"
		return
	elif [[ ${RBUFFER[1]} == ${KEYS[-1]} ]]
	then
		((++CURSOR))
	else
		LBUFFER="$LBUFFER$KEYS" 
		if [[ $LASTWIDGET == (self-insert|magic-space|backward-delete-char) || $LASTWIDGET == (complete-word|accept-*|predict-*|zle-line-init) ]]
		then
			if ! zle .history-beginning-search-backward
			then
				RBUFFER="" 
				if [[ ${KEYS[-1]} != ' ' ]]
				then
					unsetopt automenu recexact
					integer curs=$CURSOR pos nchar=${#LBUFFER//[^${KEYS[-1]}]} 
					local -a +h comppostfuncs
					local crs curcontext="predict:${${curcontext:-:::}#*:}" 
					comppostfuncs=(predict-limit-list) 
					zle complete-word
					repeat 1
					do
						zstyle -s ":predict" cursor crs
						case $crs in
							(complete) [[ ${LBUFFER[-1]} = ${KEYS[-1]} ]] && break ;&
							(key) pos=${BUFFER[(in:nchar:)${KEYS[-1]}]} 
								if [[ pos -gt curs ]]
								then
									CURSOR=$pos 
									break
								fi ;&
							(*) CURSOR=$curs  ;;
						esac
					done
				fi
			fi
		else
			zstyle -t ":predict" toggle && predict-off
		fi
	fi
	return 0
}
limit-completion () {
	if ((compstate[nmatches] <= 1))
	then
		zle -M ""
	elif ((compstate[list_lines] > 6))
	then
		compstate[list]="" 
		zle -M "too many matches."
	fi
}
predict-limit-list () {
	if (( compstate[list_lines]+BUFFERLINES > LINES ||
	( compstate[list_max] != 0 &&
	    compstate[nmatches] > compstate[list_max] ) ))
	then
		compstate[list]='' 
	elif zstyle -t ":predict" list always
	then
		compstate[list]='force list' 
	fi
}
predict-off () {
	zle -A .self-insert self-insert
	zle -A .magic-space magic-space
	zle -A .backward-delete-char backward-delete-char
	zstyle -t :predict verbose && zle -M predict-off
	return 0
}
predict-on () {
	zle -N self-insert insert-and-predict
	zle -N magic-space insert-and-predict
	zle -N backward-delete-char delete-backward-and-predict
	zle -N delete-char-or-list delete-no-predict
	zstyle -t :predict verbose && zle -M predict-on
	return 0
}
preexec () {
	echo -n "\e[39m"
}
remove-prediction () {
	if ((now_predict == 1))
	then
		BUFFER="$buffer_org" 
		now_predict=0 
	fi
}
self-insert-incr () {
	correct-prediction
	remove-prediction
	if zle .self-insert
	then
		show-prediction
	fi
}
show-prediction () {
	if ((PENDING == 0)) && ((CURSOR > 1)) && [[ "$PREBUFFER" == "" ]] && [[ "$BUFFER[CURSOR]" != " " ]]
	then
		cursor_org="$CURSOR" 
		buffer_org="$BUFFER" 
		comppostfuncs=(limit-completion) 
		zle complete-word
		cursor_prd="$CURSOR" 
		buffer_prd="$BUFFER" 
		if [[ "$buffer_org[1,cursor_org]" == "$buffer_prd[1,cursor_org]" ]]
		then
			CURSOR="$cursor_org" 
			if [[ "$buffer_org" != "$buffer_prd" ]] || ((cursor_org != cursor_prd))
			then
				now_predict=1 
			fi
		else
			BUFFER="$buffer_org" 
			CURSOR="$cursor_org" 
		fi
		echo -n "\e[32m"
	else
		zle -M ""
	fi
}
vi-backward-delete-char-incr () {
	correct-prediction
	remove-prediction
	if zle vi-backward-delete-char
	then
		show-prediction
	fi
}
vi-cmd-mode-incr () {
	correct-prediction
	remove-prediction
	zle vi-cmd-mode
}
# Shell Options
setopt autocd
setopt noautomenu
setopt autopushd
setopt correct
setopt nohashdirs
setopt histignoredups
setopt ignoreeof
setopt interactivecomments
setopt nolistbeep
setopt listpacked
setopt login
setopt promptsubst
setopt sharehistory
# Aliases
alias -- cat=bat
alias -- ctags=/usr/local/bin/ctags
alias -- diff='diff -u'
alias -- g=git
alias -- h=history-with-peco
alias -- ibrew='arch -arm64 brew'
alias -- irb=pry
alias -- kill='ps | fzf | awk '\''{print $1}'\'' | xargs -I{} kill {}'
alias -- l=eza
alias -- la='eza -a'
alias -- less='less -R'
alias -- ll='eza -l'
alias -- lla='eza -la'
alias -- ls='eza --classify=auto'
alias -- lt='eza --tree'
alias -- mfm=my_favorit_memos
alias -- mm='nvim ~/memos/memo.md'
alias -- pomo='ding in 30m -n -c '\''ffplay -nodisp -autoexit ~/.ding_music/play.* &'\'' &'
alias -- repos='cd $(ghq root)/$(ghq list > /dev/null | fzf)'
alias -- run-help=man
alias -- sv='sudo nvim'
alias -- tmux-reload='tmux source-file ~/.tmux.conf'
alias -- v=nvim
alias -- vim=nvim
alias -- weather='curl wttr.in/shibuya'
alias -- which-command=whence
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/Users/kokoax/.asdf/installs/nodejs/22.14.0/lib/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH=/Users/kokoax/.asdf/plugins/nodejs/shims\:/Users/kokoax/.asdf/installs/nodejs/22.14.0/bin\:/Users/kokoax/.asdf/shims\:/Users/kokoax/.asdf/shims\:/opt/homebrew/opt/asdf/libexec/bin\:/Users/kokoax/.rd/bin\:/opt/homebrew/opt/libpq/bin/\:/opt/homebrew/opt/php\@7.4/sbin\:/opt/homebrew/opt/php\@7.4/bin\:/Users/kokoax/.cargo/bin\:/Users/kokoax/.roswell/bin\:/Users/kokoax/.gem/ruby/2.6.0/bin\:/Users/kokoax/.kiex/bin\:/Users/kokoax/.ghq/bin\:/Users/kokoax/.ghq/bin\:/opt/homebrew/bin\:/Users/kokoax/.local/bin\:/Users/kokoax/.mybin\:/Users/kokoax/.bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/Users/kokoax/.rd/bin\:/opt/homebrew/opt/libpq/bin/\:/opt/homebrew/opt/php\@7.4/sbin\:/opt/homebrew/opt/php\@7.4/bin\:/Users/kokoax/.cargo/bin\:/Users/kokoax/.roswell/bin\:/Users/kokoax/.gem/ruby/2.6.0/bin\:/Users/kokoax/.kiex/bin\:/Users/kokoax/.ghq/bin\:/Users/kokoax/.local/bin\:/Users/kokoax/.mybin\:/Users/kokoax/.bin\:/Applications/iTerm.app/Contents/Resources/utilities\:/Users/kokoax/.asdf/installs/golang/1.16/bin\:/Users/kokoax/.asdf/installs/golang/1.23.0/bin\:/Users/kokoax/.asdf/installs/golang/1.24.3/bin\:/Users/kokoax/.asdf/installs/golang/1.16/bin\:/Users/kokoax/.asdf/installs/golang/1.23.0/bin\:/Users/kokoax/.asdf/installs/golang/1.24.3/bin
