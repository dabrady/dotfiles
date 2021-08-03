# Ported to ZSH from the Bash version here (and then made more readable in some places during said port):
# @see https://github.com/bashup/events/

function event() {
  function gecho(){}
  gecho "eventing"
  case $1 in
    error|quote|encode|decode) ;;
    *)
      __ev.encode "${2-}"
      local user_flag n='' user_event=user_event_$REPLY'[1]'
      user_flag=${user_event/event/flag}
	    case $1 in
        emit)
          shift
          # TODO what is this supposed to do?
          # ${(P)user_flag-}         # ${!f-}
          eval "${(P)user_event-}"   # eval "${!e-}"
          return ;;
        on|once|off|has)
          # NOTE(dabrady) This implements the special "total # of args accepted" specifier.
		      case "${3-}" in
            # '@_' specifies all arguments are permitted, no matter how many
            @_) n='$#';;
            # '@<any non-digits>' is not valid and is ignored
            @*[^0-9]*) ;;
            # '@<any number of digits>' specifies a specific max argument count
            @[0-9]*) n=$((${3#@}));; # take the third arg and chop off the first occurrance of the '@' symbol
          esac

          # NOTE(dabrady)
          #   ${n:+set -- "$1" "$2" "${@:4}"}
          # This says:
          #   If the variable 'n' is not the empty string, purge the third argument to this function. 😓
          # But it's not valid ZSH or readable, so converting it.
          gecho "arguments  : $@"
          if [[ ! -z "$n" ]]; then
            set -- "$1" "$2" "${@:4}"
          fi
          gecho "processed  : $@"

          # NOTE(dabrady) The pattern being matched here is:  <first argument>/<number of arguments>
          # This gives us a clever way to condense and outline logic for cases that care about both bits of info.
		      case $1/$# in
            # When first arg is "on" and there are 1 or 2 total args
			      on*/[12]) set -- error "${2-}: missing callback";;
            # When there are 1 or 2 total args
            */[12]) REPLY=;;
            # When the input has any other shape
			      *)
              __ev.quote "${@:3}"

              # NOTE(dabrady)
              # Literally, this says:
              #   If 'n' holds a number, append this string to 'REPLY'.
              # Semantically, this says:
              #   If the caller specified the callback can handle all args given to it
              #   (by passing the special "@_" flag as the 3rd positional argument to `event`)
              #   ensure all args are passed to the callback.
              ((${n/\$\#/1})) && REPLY+=' "${@:2:'"$n"'}"'
              REPLY+=$'\n'
		      esac
	    esac
  esac
  gecho -e "user_flag  : $user_flag\nuser_event : $user_event\nn: $n\nREPLY: $REPLY"
  gecho "doing the thing: $@"
  __ev."$@"
  local __event_status=$?
  unfunction gecho 2>/dev/null || true
  return $__event_status
}
__ev.error(){ echo "$1">&2;return "${2:-64}";}
function __ev.quote() {
  REPLY=
  if [[ ! -z "$@" ]]; then
    printf -v REPLY ' %q' "$@"
  fi
  REPLY=${REPLY# }
}
function __ev.has() {
  gecho "comparing $'\n'${(P)user_event-}"
  gecho "against   *$'\n'$REPLY*"
  [[ ${(P)user_event-} && $'\n'"${(P)user_event}" == *$'\n'"$REPLY"* && ! ${(P)user_flag-} ]]
}
__ev.get(){ ${(P)user_flag-};REPLY=${(P)user_event-};}
function __ev.on() {
  __ev.has && return

  if [[ ${(P)user_flag-} ]]; then
    gecho "gonna eval : ${(P)user_event-};$REPLY"
    eval "${(P)user_event-};$REPLY"
  else
    gecho "gonna eval : $user_event+='$REPLY'"
    eval "$user_event"+='$REPLY'
  fi
}
__ev.off(){ __ev.has||return 0; n="${(P)user_event}"; n=${REPLY:+"${n#"$REPLY"}"}; eval "$user_event"=$'"${n//\n"$REPLY"/\n}"';[[ ${(P)user_event} ]]||unset "${user_event%\[1]}";}
function __ev.fire() {
  gecho "firing"
  ${(P)user_flag-}
  set -- "$user_event" "${@:2}"
  while [[ ${(P)1-} ]]; do
    eval "unset ${1%\[1]};${(P)1}"
  done
}
__ev.all(){ ${(P)user_flag-};user_event=${(P)user_event-};eval "${user_event//$'\n'/||return; }";}
__ev.any(){ ${(P)user_flag-};user_event=${(P)user_event-};eval "${user_event//$'\n'/&&return|| } ! :";}
__ev.resolve(){
	${(P)user_flag-};__ev.fire "$@";__ev.quote "$@"
	printf -v n "eval __ev.error 'event \"%s\" already resolved' 70;return" "$1"; eval "${user_flag}"='$n'
	printf -v n 'set -- %s' "$REPLY"; eval "${user_event}"='$n';readonly "${user_flag%\[1]}" "${user_event%\[1]}"
}
__ev.resolved(){ [[ ${(P)user_flag-} ]];}
__ev.once(){ n=${n:-0} n=${n/\$\#/_}; event on "$1" "@$n" __ev_once $# "@$n" "$@";}
__ev_once(){ event off "$3" "$2" __ev_once "${@:1:$1+2}"; "${@:4}";}
function __ev_jit() {
	local q r=${__ev_jit-} s=$1
  ((${#r}<250)) || __ev_jit=
	while [[ "$s" ]]; do
    gecho "jitting: '${s:0:1}'"
		r=${s:0:1}
    s=${s:1}
    printf -v q %q "$r"
    eval 's=${s//'"$q}"
    printf -v r 'REPLY=${REPLY//%s/_%02x};' "${q/#[~]/[~]}" "'$r"
    eval "$r"
    __ev_jit+="$r"
	done
	eval\
    '__ev.encode(){ gecho "encoding $@"; local LC_ALL=C;REPLY=${1//_/_5f};'\
    "${__ev_jit-}"' [[ $REPLY != *[^_[:alnum:]]* ]] || __ev_jit "${REPLY//[_[:alnum:]]/}"; gecho "done encoding";}'
};__ev_jit ''
__ev.decode(){ REPLY=();while (($#));do printf -v n %b "${1//_/\\x}";REPLY+=("$n");shift;done;}
__ev.list() {
  eval 'set -- "${(P)'"${user_event%\[1]}"'@}"'
  __ev.decode "${@#user_event_}"
}
