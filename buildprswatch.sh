#!/bin/zsh
zmodload zsh/zselect

scriptpid=$$

(
  gvim -f -geometry=80x39+616+0 "$1.prs"
  kill $scriptpid
  exit
) &

while [ ! -e "$1.prs" ]; do
  # 4/10 of a second
  #usleep 400000
  zselect -t 40
done

~/gh/quickpres/quickpres.pl -a "$1".prs "$1".html
#~/gh/quickpres/quickpres.pl "$1".prs "$1".html
touch "$1.html"

#google-chrome "file://$PWD/$1.html" &
epiphany -p "file://$PWD/$1.html" &

while :; do
  if [ "$1.html" -ot "$1.prs" ]; then
    ~/gh/quickpres/quickpres.pl -a "$1".prs "$1".html
    #~/gh/quickpres/quickpres.pl "$1".prs "$1".html
    touch "$1.html"
  fi
  # 4/10 of a second
  #usleep 400000
  zselect -t 40
done
