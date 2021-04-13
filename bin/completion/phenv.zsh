#compdef phenv

local CONFIG_PATH=~/.primehub/config/$(kubectl config current-context)
local HELM_OVERRIDE_PATH=$CONFIG_PATH/helm_override
local all_override=$(ls -1 $HELM_OVERRIDE_PATH)

__basic_cmd(){
  local -a _basic_cmds
  integer ret=1
  _basic_cmds=(
    "override[Edit a custom helm override file.]"
    "edit[Edit a custom environment file ($CONFIG_PATH/.env)]"
  )
  _values 'phenv [flags] [options]' $_basic_cmds[@] && ret=0

  return ret
}


_phenv(){
  typeset -A opt_args
  integer ret=1
  local -a _flags
  _flags=(
    '--path[Show config path for curent kubernetes context]'
    '--effective-path[Show effective kubernetes context]'
    {-h,--help}'[Help about phenv command]'
  )
  _arguments \
    ${_flags[@]} \
    "1: :{_alternative ':basic_cmd:__basic_cmd'}" \
    '*:: :->args' && ret=0

  case $state in
    args)
    case $words[1] in
      override)
        _arguments \
          "*: :(${all_override})" && ret=0
      ;;
    esac
    ;;
  esac

  return ret
}

_phenv

