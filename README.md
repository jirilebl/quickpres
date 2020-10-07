# quickpres

HTML scrolling presentation for math classes with LaTeX syntax for math (using MathJax).
The advantage of a scrolling presentation over slides is that you unhide stuff slowly and
it more mimics a board.  You can "zoom out" to see more of the "board" so that past things
don't just disappear into oblivioun.

Simple syntax converted into HTML that is displayed with a web browser.
The syntax is explained in the sample presentation pres.prs.  You should
run `./quickpres.pl` in this directory to generate pres.html, which you
then view in a browser.  To see the syntax, just view the pres.prs file
in a text editor.  Internet access is required to run the presentation however
if MathJax is used, you'd have to edit the file to use a local installation.

For a demo output see the [pres.html](https://jirilebl.github.io/quickpres/pres.html) file.

I am teaching with this currently (Fall 2020) and so capability and sometimes syntax might change a bit
from day to day, though I don't really expect it to change much, I do want it to be able to read older
presentations I've done.  If you want to use this you might want to just want to fix at a specific version
unless you plan on tracking the changes to syntax.
