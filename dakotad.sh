#!/usr/bin/env zsh
zmodload zsh/net/tcp zsh/zselect

broadcast(){
	fdlist="$(ztcp -L | cut -f1,4 | grep \"$(./confparse.sh citrusd.conf listen 2)\$\" | grep -v '^11')"
	for i in $fdlist ; do
		echo "$*" >&$i
	done
}

accept(){
	read line
	grep "^N " <<<"$line"
	realname="$(perl -p -e 's/^N ([:alpha:][:alnum:]*) ([:alnum:]) ([:xdigit:]) :(.*)/$4/'<<<\"$line\")"
	userident="$(perl -p -e 's/^N ([:alpha:][:alnum:]*) ([:alnum:]) ([:xdigit:]) :(.*)/$2/'<<<\"$line\")"
	nickname="$(perl -p -e 's/^N ([:alpha:][:alnum:]*) ([:alnum:]) ([:xdigit:]) :(.*)/$1/'<<<\"$line\")"
	modemask="$(perl -p -e 's/^N ([:alpha:][:alnum:]*) ([:alnum:]) ([:xdigit:]) :(.*)/$3/'<<<\"$line\")"
	broadcast "$(./confparse.sh citrusd.conf name 2) N $nickname $userident $modemask :$realname"
}

irc-accept(){
	read user
	read nick
	grep "^NICK " <<<"$nick"
	realname="$(perl -p -e 's/^USER ([:alnum:]) ([:xdigit:]) \* :(.*)/$3/'<<<\"$user\")"
	userident="$(perl -p -e 's/^USER ([:alnum:]) ([:xdigit:]) \* :(.*)/$1/'<<<\"$user\")"
	nickname="$(perl -p -e 's/^NICK ([:alpha:][:alnum:]*)/$1/'<<<\"$nick\")"
	modemask="0008"
	broadcast "$(./confparse.sh citrusd.conf name 2) N $nickname $userident $modemask :$realname"
}

ztcp -d 10 -l "$(./confparse.sh citrusd.conf listen 1)"
ztcp -d 11 -l "$(./confparse.sh citrusd.conf listen 2)"
ztcp -d 12 -l "$(./confparse.sh citrusd.conf listen 3)"

while ztcp -a 10 ; do
	ipaddr="$(ztcp -L | grep \"^$REPLY\" | cut -f 5 -d' ')"
	theirport="$(ztcp -L | grep \"^$REPLY\" | cut -f 6 -d' ')"
	theirident="$(echo $theirport, $myport | nc $ipaddr 113)"
	grep -i '^$' <<<"$theirident" && theirident="noident"
	if test "$theirident" \!= "noident" ; then
		theirid="$(perl -p -e 's/.*://g' <<<\"$theirident\")"
	fi
	accept $REPLY "$theirid" $ipaddr &
done

while ztcp -a 11 ; do
	ipaddr="$(ztcp -L | grep \"^$REPLY\" | cut -f 5 -d' ')"
	theirport="$(ztcp -L | grep \"^$REPLY\" | cut -f 6 -d' ')"
	theirident="$(echo $theirport, $myport | nc $ipaddr 113)"
	grep -i '^$' <<<"$theirident" && theirident="noident"
	if test "$theirident" \!= "noident" ; then
		theirid="$(perl -p -e 's/.*://g' <<<\"$theirident\")"
	fi
	srv-accept $REPLY "$theirid" $ipaddr &
done

while ztcp -a 12 ; do
	ipaddr="$(ztcp -L | grep \"^$REPLY\" | cut -f 5 -d' ')"
	theirport="$(ztcp -L | grep \"^$REPLY\" | cut -f 6 -d' ')"
	theirident="$(echo $theirport, $myport | nc $ipaddr 113)"
	grep -i '^$' <<<"$theirident" && theirident="noident"
	if test "$theirident" \!= "noident" ; then
		theirid="$(perl -p -e 's/.*://g' <<<\"$theirident\")"
	fi
	irc-accept $REPLY "$theirid" $ipaddr &
done


