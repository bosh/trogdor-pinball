alias t='cd ~/workspace/trogdor-pinball'

#-b removes bcp dependency
#-t changes to log mode
#-V verbose logging
#-x/X dumb/smart virtual interface to remove hardware dependency
alias snake="clear; t; mpf game -bt" #log tail with no bcp connection required
alias vsnake="tmonitor& clear; t; mpf game -btX" #log tail with no bcp connection required, virtual mode?
alias tmonitor="t; mpf monitor"

alias trogdor="clear; t; mpf game" #requires bcp connection
alias tmc="echo TODO" #to run the mc or gmc +bcp client #probably mpf gmc ...

alias mpfpenv=". ~/mpf80env/bin/activate"
