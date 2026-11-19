#!/bin/bash
sudo apt update
sudo apt install software-properties-common
sudo apt install python3-pip
python3 -m pip --version
cd /workspaces/pe-architect-course/workshop/teams-management/cli
pip install -r requirements.txt
sudo ln -s $(pwd)/teams_cli.py /usr/local/bin/teams-cli
