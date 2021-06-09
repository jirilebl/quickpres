#!/usr/bin/perl

my ($opt, $infile, $outfile) = @ARGV;
my $allatonce = 0;
my $iniallatonce = 0;
my $newlineratio = 0.9;
my $draftmode = 0;

my $macros = "";

if (defined $opt) {
	if ($opt =~ m/^-a/) {
		$allatonce = 1;
		$iniallatonce = 0;
	} elsif ($opt =~ m/^-A/) {
		$iniallatonce = 1;
		$allatonce = 0;
	} elsif ($opt =~ m/^-h/) {
		$newlineratio = 0.8;
	} elsif ($opt =~ m/^-H/) {
		$newlineratio = 0.7;
	} elsif ($opt =~ m/^--help/) {
		print "quickpres.pl <option> <in> <out>\n";
		print "one option, could be\n";
		print "-a = all at once, nohiding\n";
		print "-A = initially all shown\n";
		print "-h = new stuff shown at 80% (normally 90%)\n";
		print "-H = new stuff shown at 70%\n";
		print "Use '!-<option>' as first line, can specify\n";
		print "multiple options that way\n";
		exit 0;
	} elsif ($opt =~ m/^-/) {
		die "unknown option";
	} else {
		($infile, $outfile) = @ARGV;
	}
}

if (not defined $infile) {
	$infile = "pres.prs";
}

if (not defined $outfile) {
	$outfile = $infile;
	if (not $outfile =~ s/\.[^.]*$/.html/) {
		$outfile = $infile . ".html";
	}
}

print "\nquickpres.pl\n";
print "reading: $infile    writing: $outfile\n";

if ($allatonce) { print "  all at once,"; }
if ($iniallatonce) { print "  initially all at once,"; }

print "  new line ratio: $newlineratio\n";

open(my $in,'<', $infile) or die $!; 
open(my $out, '>', $outfile) or die $!; 

my $indiv = 0;
my $dopar = 0;
my $skippar = 0;
my $gottitle = 0;

my $title = "Presentation";

my $outstr;

my $lineno = 0;

my $inbullet = 0;

sub closebullet {
	if ($inbullet == 1) {
		$outstr .= "</ul>\n";
	}
	$inbullet = 0;
}

sub newpar {
	if ($dopar == 1 and $skippar == 1) {
		$outstr .= "<p>\n";
	} else {
		$outstr .= "<p class=\"noskip\">\n";
	}
}

# No \input file reading here (FIXME?)
while($line = <$in>)
{
	chomp($line);

	$line =~ s/\s+$//;

	$lineno++;

	if ($lineno == 1 and $line =~ m/^!!!DRAFT!!!$/) {
		print "DRAFT: setting -a mode and turning on watermark\n";
		$allatonce = 1;
		$iniallatonce = 0;
		$draftmode = 1;
	} elsif ($lineno == 1 and $line =~ m/^!(-.*)\s*$/) {
		$o = $1;
		print "found options line: $o\n";
		@opts = split(' ', $o);
		foreach my $i (@opts) {
			if ($i eq "-a") {
				print "Found -a, setting allatonce mode\n";
				$allatonce = 1;
				$iniallatonce = 0;
			} elsif ($i eq "-A") {
				print "Found -A, setting iniallatonce mode\n";
				$iniallatonce = 1;
				$allatonce = 0;
			} elsif ($i eq "-h") {
				print "Found -h, setting newlineratio to 0.8\n";
				$newlineratio = 0.8;
			} elsif ($i eq "-H") {
				print "Found -H, setting newlineratio to 0.7\n";
				$newlineratio = 0.7;
			} else {
				print "Unknown option $i, ignoring\n";
			}
		}
	} elsif ($line =~ s/^!\\newcommand//) {
		$macros .= "\\newcommand$line\n";
	} elsif ($line =~ s/^!\\renewcommand//) {
		$macros .= "\\renewcommand$line\n";
	} elsif ($line =~ s/^###\s*//) {
		closebullet();
		$outstr .= "<h3>$line</h3>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ s/^##\s*//) {
		closebullet();
		$outstr .= "<h2>$line</h2>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ s/^#\s*//) {
		closebullet();
		if ($gottitle == 0) {
			$gottitle = 1;
			$title = $line;
		}
		$outstr .= "<h1>$line</h1>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ s/^[*]\s+//) {
		closebullet();
		if ($skippar == 1) {
			$outstr .= "<p>\n";
		}
		$outstr .= "<ul><li>$line\n";
		$inbullet = 1;
		$dopar = 0;
		$skippar = 0;
	} elsif ($line =~ m/^[(](http.*)[)]$/) {
		if ($dopar == 1) {
			newpar();
		}
		$outstr .= "<a href=\"$1\">$1</a>\n";
		$dopar = 0;
		$skippar = 0;
	} elsif ($line =~ m/^\[([^]]*)\][(](http.*)[)]$/) {
		if ($dopar == 1) {
			newpar();
		}
		$outstr .= "<a href=\"$2\">$1</a>\n";
		$dopar = 0;
		$skippar = 0;
	} elsif ($line =~ m/^!!![(](.*)[)]$/) {
		closebullet();
		newpar();
		$outstr .= "<img class=\"chhimage\" src=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^!!!\[([^]]*)\][(](.*)[)]$/) {
		closebullet();
		newpar();
		$outstr .= "<img class=\"chhimage\" src=\"$2\" alt=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^!![(](.*)[)]$/) {
		closebullet();
		newpar();
		$outstr .= "<img class=\"chimage\" src=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^!!\[([^]]*)\][(](.*)[)]$/) {
		closebullet();
		newpar();
		$outstr .= "<img class=\"chimage\" src=\"$2\" alt=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^![(](.*)[)]$/) {
		closebullet();
		newpar();
		$outstr .= "<img class=\"cimage\" src=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^!\[([^]]*)\][(](.*)[)]$/) {
		closebullet();
		newpar();
		$outstr .= "<img class=\"cimage\" src=\"$2\" alt=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^[>](.*)[<]\s*$/) {
		closebullet();
		if ($dopar == 1 and $skippar == 1) {
			$outstr .= "<p class=\"centered\">\n";
		} else {
			$outstr .= "<p class=\"noskip centered\">\n";
		}
		$outstr .= "$1\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^\\$/) {
		closebullet();
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^$/) {
		closebullet();
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ m/^---$/) {
		closebullet();
		$outstr .= "<hr>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ m/^___$/) {
		closebullet();
		$outstr .= "<div style=\"height:2in;\"></div>\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^>>>$/) {
		closebullet();
		if ($indiv == 1) { 
			$outstr .= "</div>\n";
		}
		if ($allatonce == 1 or $iniallatonce == 1) {
			$outstr .= "<div class=\"qpcontent\">\n";
		} else {
			$outstr .= "<div class=\"qpcontent\" style=\"display:none;\">\n";
		}
		$indiv = 1;
		$dopar = 1;
	} elsif ($line =~ m/^_([^_]+)_([^_]*)$/) {
		if ($dopar == 1) {
			newpar();
		}
		$dopar = 0;
		$skippar = 0;
		$outstr .= "<strong>$1</strong>$2\n";
	} elsif ($line =~ m/^[*]([^*]+)[*]([^*]*)$/) {
		if ($dopar == 1) {
			newpar();
		}
		$dopar = 0;
		$skippar = 0;
		$outstr .= "<em>$1</em>$2\n";
	} elsif ($line =~ m/^%/) {
		# do nothing, it's a comment
	} else {
		if ($dopar == 1) {
			newpar();
		}
		$dopar = 0;
		$skippar = 0;
		$outstr .= "$line\n";
	}
}

closebullet();

if ($indiv == 1) { 
	$outstr .= "</div>\n";
}

print $out <<END;
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>$title</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
MathJax = {
  tex: {
    inlineMath: [['\$','\$'],['\\\\(','\\\\)']]
  }
};
</script>
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6%2CscrollIntoView"></script> 
<script id="MathJax-script" async 
 src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"> 
</script> 
<style>
html { scroll-behavior: smooth; }
span.small {font-size:67%;}
span.tiny {font-size:50%;}
span.large {font-size:150%;}
span.huge {font-size:200%; }
span.tt {font-family: Courier, "Courier New", monospace;}
h1 {font-size:180%; font-weight:bold;}
h2 {font-size:120%; font-weight:bold;}
h3 {font-size:100%; font-weight:bold;}
body { 
	font-family: Tex Gyre Pagella, Palatino, URW Palladio L, Palatino Linotype, Palatino LT STD, Book Antiqua, Georgia, serif;
        line-height: 1.5;
	font-size: 180%;
	background-color:#ffffff;
	color:#000000; 
}
a:link {color:#900b09; background-color:transparent; }
a:visited {color:#500805; background-color:transparent; }
\@media print {
 a:visited {color:#900b09; background-color:transparent; }
}
a:hover {color:#ff0000; background-color:transparent; }
a:active {color:#ff0000; background-color:transparent; }
.centered {text-align:center;}
h1 {text-align:left;}
h2 {text-align:left;}
h3 {text-align:left;}
.cimage { display:block; max-width: 90%; margin-left: auto; margin-right: auto; }
.chimage { display:block; max-width: 50%; margin-left: auto; margin-right: auto; }
.chhimage { display:block; max-width: 25%; margin-left: auto; margin-right: auto; }
div#thebody {margin-top:20px; margin-left: 5%; margin-right:5%; max-width:1100px;}
h3 {margin-left:-2%;}
h2 {margin-left:-2%;}
h1 {margin-left:-2%;}
p.left {margin-left:-2%;}
p { margin-bottom:0px; margin-top:20px; }
p.noskip { margin-top:0px; }
ul { margin-top:0px; margin-bottom:0px; margin-left:0px; padding-left:1em; list-style:square;}
hr { margin-bottom:20px; margin-top:20px; }
mjx-container { margin:0px !important; }
\@media print {
  #endspacediv { display:none; }
  #endspan { display:none; }
}
\@media screen {
  #endspacediv { height:6in; }
}
#logo { font-size:40%; color:gray; text-align:right;}
</style>
</head>

<body>
END

if ($macros ne "") {
	print $out <<END
<div style="display:none">
\\($macros\\)
</div>
END
}

if ($draftmode == 1) {
print $out <<END;
<div style="position:absolute; z-index:-1;">
  <p style="font-size:700%; color:lightgray; transform:rotate(-45deg);">DRAFT</p>
  <p style="font-size:700%; color:lightgray; transform:rotate(-45deg);">DRAFT</p>
  <p style="font-size:700%; color:lightgray; transform:rotate(-45deg);">DRAFT</p>
</div>
END
}

if ($allatonce == 0) {
print $out <<END;
<script>
function doenter() {
  var rect = \$("#endspan")[0].getBoundingClientRect();

  if(rect.top <= 0) {
    \$elt = \$( ".qpcontent:hidden" ).first();
    \$elt.fadeIn( 400 );
    \$elt[0].scrollIntoView({ behavior: "smooth", block: "start" });
  } else if(rect.top <= (window.innerHeight || document.documentElement.clientHeight) * 0.8) {
    \$elt = \$( ".qpcontent:hidden" ).first();
    \$elt.fadeIn( 400 );
  } else {
    window.scrollBy({ 
      top: 120, // could be negative value
      left: 0, 
      behavior: 'smooth' 
    });
  }
}
\$( document.body ).keydown(function( event ) {
  if (event.key == "A") {
    \$( ".qpcontent:hidden" ).fadeIn( 400 );
  } else if (event.key == "B") {
    \$( ".qpcontent:visible" ).fadeOut( 200 , function () {
      \$("html")[0].scrollIntoView({ behavior: "smooth", block: "start" });
    });
  } else if (event.key == "J") {
    \$( ".qpcontent:hidden" ).first().fadeIn( 400 );
  } else if ( event.key == "K" ) {
    \$( ".qpcontent:visible" ).last().fadeOut( 200 );
  } else if (event.key == "j") {
    \$elt = \$( ".qpcontent:hidden" ).first();
    \$elt.fadeIn( 400 );
    if (\$elt[0].getBoundingClientRect().height > window.innerHeight*$newlineratio) {
      window.scrollTo({
	   top: \$elt[0].getBoundingClientRect().top+window.scrollY,
           behavior: "smooth"
      });
    } else {
      window.scrollTo({
	   top: \$elt[0].getBoundingClientRect().bottom-window.innerHeight*$newlineratio+window.scrollY,
           behavior: "smooth"
      });
    }
  } else if (event.key == "n" || event.key == "Enter") {
    doenter();
  } else if (event.key == "k" || event.key == "Backspace") {
    \$( ".qpcontent:visible" ).last().fadeOut( 200 , function () {
      \$elt = \$( ".qpcontent:visible" ).last();
      if (\$elt.length == 0) {
        \$("html")[0].scrollIntoView({ behavior: "smooth", block: "start" });
      } else {
        if (\$elt[0].getBoundingClientRect().height > window.innerHeight*$newlineratio) {
          window.scrollTo({
	       top: \$elt[0].getBoundingClientRect().top+window.scrollY,
               behavior: "smooth"
          });
        } else {
          window.scrollTo({
	       top: \$elt[0].getBoundingClientRect().bottom-window.innerHeight*$newlineratio+window.scrollY,
               behavior: "smooth"
          });
	}
      }
    } );
  } else if ( event.key == "e") {
    \$("#endspan")[0].scrollIntoView({ behavior: "smooth", block: "end" });
  }
});
</script>
END
}

print $out <<END;
<div id=thebody>
END

print $out $outstr;

print $out <<END;

<div id="endspacediv"><span id="endspan">&nbsp;</span></div>
<div id="logo">made in quickpres.pl</div>

</div>

</body>
</html>
END

close ($in); 
close ($out); 

print "done\n";
