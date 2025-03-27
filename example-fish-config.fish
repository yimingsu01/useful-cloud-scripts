if status is-interactive
    # Adding go bin to path
    # Adding go binaries path to path
    # Commands to run in interactive sessions can go here
end


fish_add_path $HOME/go/bin
fish_add_path /usr/local/go/bin
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"