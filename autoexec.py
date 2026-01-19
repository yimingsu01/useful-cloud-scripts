#! /usr/bin/env python3
import subprocess
import concurrent.futures

scripts_to_run = [
    "brew.sh",
    "docker.sh",
    "go.sh"
]

def run_script(script):
    subprocess.run(["bash", script], cwd=".", check=True, executable="/usr/bin/zsh")

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

with concurrent.futures.ThreadPoolExecutor() as executor:
    executor.map(run_script, scripts_to_run)
