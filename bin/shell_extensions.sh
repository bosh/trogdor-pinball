alias t='cd ~/workspace/trogdor-pinball'
alias m='cd ~/workspace/mpf'
alias md='cd ~/workspace/mpf-docs'
alias mg='cd ~/workspace/mpf-gmc'
alias mm='cd ~/workspace/mpf-monitor'
alias mh='cd ~/workspace/mpf-hardware'
alias mpfm='mpf monitor & mpf ' # Root call for many other calls with monitor added on

#-b removes bcp dependency
#-t changes to log mode
#-V verbose logging
#-x/X dumb/smart virtual interface to remove hardware dependency
#-g GMC project directory
#-G GMC executable if not on path
alias vsnake="clear; t; mpfm game -btX -c env_cabinet.yaml" #Used by windows taskbar integration - monitor, no gmc, smart_virtual, cabinet config

#'both' requires godot executable on the path
alias vboth="clear; t; mpfm both -g gmc -tXp"
alias minilive="clear; t; mpf both -g gmc -t -c env_minicab.yaml"

alias tmedia='~/workspace/pinball-media/pinball-media.rb install trogdor'
alias tmediax='~/workspace/pinball-media/pinball-media.rb clean trogdor'

alias mpftest="python -m unittest discover mpf/tests"
alias mpfpenv=". ~/mpf80env/bin/activate"

alias tplay="t; godot --path gmc/"
alias wprod="clear; t; mpf both -t -c env_cabinet.yaml" #windows has godot on the path
alias prod="clear; t; mpf both -t -g gmc -G ~/Desktop/Godot_v4.3-stable_linux.x86_64 -c env_cabinet.yaml" #linux has godot on the desktop for now
