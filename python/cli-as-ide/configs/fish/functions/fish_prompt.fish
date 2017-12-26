function fish_prompt
    set_color --bold $fish_color_cwd
    echo -n (whoami)@(hostname)' '
    
    set_color blue
    echo -n (pwd | sed "s|^$HOME|~|")
    
    set_color purple
    echo -n -s (__fish_git_prompt) ' ' 
    
    if set -q VIRTUAL_ENV
        set_color yellow
        echo -n -s "(" (basename "$VIRTUAL_ENV") ")"
    end

    set_color --bold $fish_color_cwd
    echo
    echo -n '$ '
    set_color normal
end
