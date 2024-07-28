#should extract to diff project
alias w='cd ~/workspace/'
alias e=explorer
alias o=open

alias m='cd ~/workspace/mpf'
alias md="cd ~/workspace/mpf-docs"

# run once
git config --global core.editor 'vim'
git config --global user.name 'Alex Lobascio'
git config --global user.email 'alex@lobasc.io'
git config --global alias.w whatchanged
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.last 'log -1 HEAD'
