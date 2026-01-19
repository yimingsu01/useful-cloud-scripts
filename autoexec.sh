#!/usr/bin/env python3
import subprocess
import concurrent.futures
import shutil
import os
from pathlib import Path

scripts_to_run = [
    "brew.sh",
    "docker.sh",
    "go.sh"
]

print("installing oh my zsh")
subprocess.run(["touch", os.path.expanduser("~/.zshrc")], check=True, executable="/bin/bash")
omz_line = 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
subprocess.run(omz_line, shell=True, cwd=".", check=True)

def run_script(script):
    subprocess.run(["bash", script], cwd=".", check=True, executable="/usr/bin/zsh")
print(f"Running initial setup scripts: {scripts_to_run}")
with concurrent.futures.ThreadPoolExecutor() as executor:
    executor.map(run_script, scripts_to_run)

scripts_to_run = [
    "helm.sh",
    "k9s.sh",
    "kind.sh",
    "kubectl.sh",
    "lazygit.sh"
]

subprocess.run(["brew", "install", "uv", "python@3.12", "python@3.13"], cwd=".", check=True, executable="/usr/bin/zsh")

print(f"Running secondary setup scripts: {scripts_to_run}")
with concurrent.futures.ThreadPoolExecutor() as executor:
    executor.map(run_script, scripts_to_run)

subprocess.run(["brew", "cleanup"], cwd=".", check=True, executable="/usr/bin/zsh")
print("Installing neovim via apt")
subprocess.run(["sudo", "apt", "install", "neovim"], cwd=".", check=True, executable="/usr/bin/zsh")

print("copying neovim config")
shutil.copytree("./nvim.bak", "~/.config", dirs_exist_ok=True)
os.rename("~/.config/nvim.bak", "~/.config/nvim")

print("copying tmux config")
shutil.copyfile("./tmux.conf", "~/.tmux.conf")

print("changing default shell to zsh")
subprocess.run(['chsh', '-s', "/usr/bin/zsh", "yimingsu"], check=True)
