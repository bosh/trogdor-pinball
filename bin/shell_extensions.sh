alias t='cd ~/workspace/trogdor-pinball'
alias m='cd ~/workspace/mpf'
alias md='cd ~/workspace/mpf-docs'
alias mg='cd ~/workspace/mpf-gmc'
alias mpfm='mpf monitor & mpf ' # Root call for many other calls with monitor added on

#-b removes bcp dependency
#-t changes to log mode
#-V verbose logging
#-x/X dumb/smart virtual interface to remove hardware dependency
#-g GMC project directory
#-G GMC executable if not on path
alias vsnake="clear; t; mpfm game -btX" #log tail with no bcp connection required, virtual mode? # Used by windows taskbar integration
alias vboth="clear; t; mpfm both -g gmc -tX" #requires godot executable on the path

alias tmedia='~/workspace/pinball-media/pinball-media.rb install trogdor'
alias tmediax='~/workspace/pinball-media/pinball-media.rb clean trogdor'

alias mpftest="python -m unittest discover mpf/tests"
alias mpfpenv=". ~/mpf80env/bin/activate"
