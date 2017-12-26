set fish_greeting ""
set PATH $HOME/.local/bin $PATH

eval (python3 -m virtualfish)
# for virtualenv activation using only my prompt
set VIRTUAL_ENV_DISABLE_PROMPT yes

fish_vi_mode
