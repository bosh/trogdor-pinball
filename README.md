TROGDOR!

He was a man
I mean, he was a dragon man
Or maybe he was just a dragon

But he was still TROGDOR!
TROGDOOOOOORR

Burninating the countryside
Burninating the peasants
Burninating all the peoples
And their thatch-roofed cottages!
THATCHED ROOF COTTAGES!!!1!1one



-----


Trogdor Pinball is built on the FAST Neuron hardware stack using MPF, the Mission Pinball Framework

Game features include:
- Beefy muscle arm upper flipper
- More different S reverso-ramp and wireform
- Your Head A Splode minigame
- Miniatures from the Kickstarter board game
- The Cheat Commando multiball
- THATCHED ROOF COTTAGE JET BUMPERS
- The King of Town. That's right.

```
                                 \|/                             ___
                                  |`._                          '.  \
               \|/                |   `-._                       ,--/.
           __,-'\                 |_     /                        --  \
           `.    \               !  `-. (                       .-,   /
             \,-' \              |`-. /¯                        `--`.'
             '-.,  `.           /  ,-'                \      /       )
                 \ / '._       / ,'                    \    /      ,'
                 '--.,_ `-._,-'¯¯¯¯¯`~-.,_              \  /    _
                       ¯`,'               ¯`'-.,_      @ \/ @ ,'_\
                       _/                        ¯``---------' (_)\
                ___ ,'¯!                                          |
            ,'¯¯   ¯`  !               __           ______________|
           /            \           ,'¯  ¯`-._      \   \/ \/\/ \|
          !         ,    \         !          `._    `-._/\   ,
          |        /      \        \             `-._    ¯`'./_\
          !     _,'      / `.     v `.               ¯`-._     ¯|
           \   ¯       ,'    `. v   v `._                 ¯`'~--'
         ,'¯   -. __,-'        `._ v  v  `._          
         \       `.               `-._      `-._
          `. ,     \                  ¯`-._     `-._
           \  `.    !                      `-._     `-._
            `.  `-  !                          `._      `.
              `.   /___                           `.      \
                `.   __)                            \      \
                 |   --:                            !      !
                 `.__.-'                            !      !
                                                    !      !
                                                   !      !
                                           |`-._  /      /
                                     |\     \   `/      /
                            .   |\   | \     \.-¯`    ,`
                            \`. | \  |  `._.-'     _.'
                             `.`'-.\_!_-'¯     _.-'
                               ¯'-.,_    _,.'`¯
                                     ¯|¯¯  |
                                      !    |
                                     !     |
                                     |     |  __,,-
                                     |     '¯¯
                                     |____

```

---

## Development

Currently built on mpf v0.80.0.dev6
and edge mpf-gmc (on Godot v4.4)
with monitor v0.57.1
on windows and linux

trogbuild is a ruby script built on ruby 3.2.2
currently it only depends on the stdlib :)))

## Commands

Add the tsource command from bin/shell_one_time_setup.sh to your shell profile.
This adds a hook to load the commands from bin/shell_extensions.sh

`mpfm` runs monitor and allows option passing, making it the new most commonly run command

`vsnake` runs monitor and the logging game window together.

`trogdor` runs the logging game instance against a live table

`ruby trogbuild.rb [-x]` will regenerate the generated modes, shows, and hooks. Default dry run, or -x to write.

## Media

Audio and other media files are maintained as stubs in this repository. A separate, private repo contains all of the real assets, with commands to substitute stubs or real files based on a map, and to do other media management tasks. Stubs generally come from https://github.com/mathiasbynens/small
