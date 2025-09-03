if status is-interactive
    # Commands to run in interactive sessions can go here
    set --global --export HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew

    set --global --export HOMEBREW_CELLAR /home/linuxbrew/.linuxbrew/Cellar

    set --global --export HOMEBREW_REPOSITORY /home/linuxbrew/.linuxbrew
    # fish_add_path --global /Users/yms/sdk/go1.23.0/bin
    # fish_add_path --global /Users/yms/go/bin
    # fish_add_path --global --move --path /opt/homebrew/bin /opt/homebrew/sbin

    # fish_add_path /opt/homebrew/opt/node@22/bin
    # if test -n "$MANPATH[1]"
    #     set --global --export MANPATH '' $MANPATH
    # end

    # if not contains /opt/homebrew/share/info $INFOPATH
    #     set --global --export INFOPATH /opt/homebrew/share/info $INFOPATH
    # end

    cd ~
end

fish_add_path /usr/local/go/bin
fish_add_path /home/yiming34/go/bin
fish_add_path /home/yiming34/.local/share/JetBrains/Toolbox/scripts/
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
