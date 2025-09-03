function gs --wraps='ssh-add' --description 'alias ssh-add=ssh-add.exe'
  ssh-add.exe $argv
        
end
