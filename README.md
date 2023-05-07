# quickpres

HTML scrolling presentation for math classes with LaTeX syntax for math (using
MathJax).  The advantage of a scrolling presentation over slides is that you
unhide stuff slowly and it more mimics a board.  You can "zoom out" to see more
of the "board" so that past things don't just disappear into oblivioun.

Simple syntax converted into HTML that is displayed with a web browser.  The
syntax is explained in the sample presentation pres.prs.  You should run
`./quickpres.pl` in this directory to generate pres.html, which you then view
in a browser.  To see the syntax, just view the pres.prs file in a text editor.
Internet access is required to run the presentation however if MathJax is used,
you'd have to edit the file to use a local installation.

For a demo output see the
[pres.html](https://jirilebl.github.io/quickpres/pres.html) file.

## Some more hacky scripts

The `runinfirefox.sh` is a very simple script that when passed the name without
extension say `./runinfirefox.sh pres` will start a python http server and runs
firefox on pres.html.  This will work only if you have Linux.

The `buildprswatch.sh` is an even more Linux/GNOME specific script for writing
presentations.  You need zsh, epiphany (gnome web), and gvim.  You start it as
`./buildprswatch.sh pres` and it starts an editor on pres.prs, starts epiphany
on pres.html.  Whenever you save, the script will rerun quick press (with -A),
and epihpany automatically reloads.  You might need to edit this script to suit.
