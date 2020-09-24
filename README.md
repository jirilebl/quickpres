# quickpres
HTML scrolling presentation for math classes.  Can show the presentation progressively in chucks.
To show the next chunk, press j or Enter, to hide the last chunk shown press k or backspace.
You have to use arrow keys or touchpad to actually scroll.

Syntax is easy, slightly similar to markdown

```
# first level heading
## second level heading
### third level heading

Leave empty lines
to separate paragraphs

Like this

If you want to hide the next chuck, put a .D on a separate line:

.D
Probably want to add an empty line, but really it is a new html division,
so it will always include a new paragraph.  So .D cannot really split up paragraphs or displayed math.

Math can be included as $x^2$ or \(x^2\) for inline math (using latex).  Dollar sign
needs to be escaped as usual: \$.

Display math should be done with \[ \] or $$ $$ as in
$$
\int_0^1 x^2\, dx
$$
```

Run the command `./quickpres.pl in.prs out.html`

Or just `./quickpres.pl` to just default to pres.prs for the input and pres.html for the output.

You can run `./quickpres.pl -a in.prs out.html` to skip the showing of blocks progressively and just show them all.`
