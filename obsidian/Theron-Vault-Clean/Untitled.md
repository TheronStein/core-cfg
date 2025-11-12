I haven't tried to make dockers yet or connect to them, I plan on having dockers on my remote server as well as a few local ones. I don't have any specific naming patterns, but I could be convinced to utilize them. I am looking for a base to work with so I can start expanding the environment and making these containers and so forth. i kind of want to make a base archlinux docker container as a base so I can configure all of this outside of my live environment.

ssh hosts can be defined from ~/.ssh/known_hosts i still have to make my passwordless access again but i do plan on integrating it, I can do that before we start if necessary.

ideally the naming scheme would be somehthing like...

Theron@cachy-asus (local) (normal hostname is cachyos-asusfx)

Theron@(defined name).docker.(shortdomain)

Theron@chaoscore.org (remote server)

I can make a hostname definitions file

name: cachyos-asusfx short-domain: cachy-asus

name: chaoscore.org shortdomain: chaoscore

then the defined names list would be like

frontend archlinux cachyos nvidia backend etc..

the launcher can make new local sessions and containers, however remote sessions can be handled on the server itself.

if i select a docker that doesnt have tmux installed, install tmux onto it and modify the dockerfile to install it.

give me in depth session information, with a large window preview of windows, and other statistics, we can define more later.

color schemes are going to be selected at random from the favorites.txt, if it doesnt exist then use the default color scheme.