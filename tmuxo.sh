#!/bin/bash
SHELL=/bin/bash

config=~/.config/tmuxo/tmuxo.toml
if [ ! -f "$config" ]; then
    echo "WARN: configuration not found"
    echo "WARN: creating with empty"
    mkdir ~/.config/tmuxo -p
    touch $config
fi

tmuxo_session_from_config() {
  sessions=$(fx --toml "$config" .session)
  echo $sessions
}

tmuxo_session_from_tmux() {
  sessions=$(tmux list-sessions -F '#{session_name}')
  echo $sessions
}

tmuxo_session_find() {
  session_from_config_s=$(printf '%s' $(tmuxo_session_from_config))
  sessions=$(echo $session_from_config_s | fx @.name list)
  sessions+=' '$(tmuxo_session_from_tmux)
  selected=$(echo $sessions \
    | tr ' ' '\n' \
    | sort -ur \
    | fzf \
      --preview "echo '$session_from_config_s' | fx '?.name == \"{}\"' '.[0]'" )
  if [[ -z "$selected" ]]; then
    echo ""
    return
  fi

  selected_data=$(echo "$session_from_config_s" | fx "?.name == '$selected'" ".[0] || null")
  if [[  "$selected_data" != "null"  ]]; then
    echo $selected_data
    return
  fi

  printf '{"name":"%s"}' $selected
}

tmuxo_session_new() {
  tmux new-session -d -D -P -F '#{session_id}:#{session_name}' -s $1 -c $2
}

tmuxo_session_attach() {
  if [[ -z $TMUX ]]; then
    tmux attach-session -t $1
    return
  fi

  tmux switch-client -t $1
}

expand_home() {
    local input="$1"
    if [[ "$input" == "~/"* ]]; then
        echo "${HOME}/${input:2}"
        return
    fi

    if [[ "$input" == "~" ]]; then
        echo "$HOME"
        return
    fi   
    
    echo "$input"
}

main() {
  session_selected=$(tmuxo_session_find)
  if [[ -z $session_selected ]]; then
    exit 0
  fi
  session_selected_name=$(echo $session_selected | fx '.name')
  session_selected_path=$(echo $session_selected | fx '.path')

  if tmux has-session -t $session_selected_name 2>/dev/null; then
    tmuxo_session_attach $session_selected_name
  else 
    tmuxo_session_new $session_selected_name $(expand_home $session_selected_path)
    tmuxo_session_attach $session_selected_name
  fi
}
main

