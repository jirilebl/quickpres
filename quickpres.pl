#!/usr/bin/perl

my ($opt, $infile, $outfile) = @ARGV;
my $allatonce = 0;

if (defined $opt) {
	if ($opt =~ m/^-a/) {
		$allatonce = 1;
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
	$outfile = "pres.html";
}

print "reading: $infile    writing: $outfile    all at once: $allatonce\n";

open(my $in,'<', $infile) or die $!; 
open(my $out, '>', $outfile) or die $!; 

my $indiv = 0;
my $dopar = 0;
my $skippar = 0;
my $gottitle = 0;

my $title = "Presentation";

my $outstr;

# No \input file reading here (FIXME?)
while($line = <$in>)
{
	chomp($line);
	$line =~ s/^\s+//;
	$line =~ s/\s+$//;
	if ($line =~ s/^###\s*//) {
		$outstr .= "<h3>$line</h3>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ s/^##\s*//) {
		$outstr .= "<h2>$line</h2>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ s/^#\s*//) {
		if ($gottitle == 0) {
			$gottitle = 1;
			$title = $line;
		}
		$outstr .= "<h1>$line</h1>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($dopar == 1 and $line =~ s/^[*]\s*//) {
		$outstr .= "<ul><li>$line</ul>\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^[(](http.*)[)]$/) {
		if ($dopar == 1 and $skippar == 1) {
			$outstr .= "<p>\n";
		} else {
			$outstr .= "<p class=\"noskip\">\n";
		}
		$outstr .= "<a href=\"$1\">$1</a>\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^\[([^]]*)\][(](http.*)[)]$/) {
		if ($dopar == 1 and $skippar == 1) {
			$outstr .= "<p>\n";
		} else {
			$outstr .= "<p class=\"noskip\">\n";
		}
		$outstr .= "<a href=\"$2\">$1</a>\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^[!][(](.*)[)]$/) {
		if ($dopar == 1 and $skippar == 1) {
			$outstr .= "<p>\n";
		} else {
			$outstr .= "<p class=\"noskip\">\n";
		}
		$outstr .= "<img class=\"cimage\" src=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^[!]\[([^]]*)\][(](.*)[)]$/) {
		if ($dopar == 1 and $skippar == 1) {
			$outstr .= "<p>\n";
		} else {
			$outstr .= "<p class=\"noskip\">\n";
		}
		$outstr .= "<img class=\"cimage\" src=\"$2\" alt=\"$1\">\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^\\$/) {
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^$/) {
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ m/^---$/) {
		$outstr .= "<hr>\n";
		$dopar = 1;
		$skippar = 1;
	} elsif ($line =~ m/^___$/) {
		$outstr .= "<div style=\"height:2in;\"></div>\n";
		$dopar = 1;
		$skippar = 0;
	} elsif ($line =~ m/^>>>$/) {
		if ($indiv == 1) { 
			$outstr .= "</div>\n";
		}
		if ($allatonce == 1) {
			$outstr .= "<div class=\"content\">\n";
		} else {
			$outstr .= "<div class=\"content\" style=\"display:none;\">\n";
		}
		$indiv = 1;
		$dopar = 1;
	} elsif ($line =~ m/^_([^_].*)_$/) {
		if ($dopar == 1) {
			if ($skippar == 1) {
				$outstr .= "<p>\n";
			} else {
				$outstr .= "<p class=\"noskip\">\n";
			}
		}
		$dopar = 0;
		$skippar = 0;
		$outstr .= "<b>$1</b>\n";
	} else {
		if ($dopar == 1) {
			if ($skippar == 1) {
				$outstr .= "<p>\n";
			} else {
				$outstr .= "<p class=\"noskip\">\n";
			}
		}
		$dopar = 0;
		$skippar = 0;
		$outstr .= "$line\n";
	}
}

if ($indiv == 1) { 
	$outstr .= "</div>\n";
}

print $out <<END;
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>$title</title>
<link rel="stylesheet" type="text/css" href="style.css"> 
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
 src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js"> 
</script> 
<style>
html { scroll-behavior: smooth; }
span.smaller {font-size:80%;}
span.tiny {font-size:60%;}
span.larger {font-size:120%;}
span.largerbold {font-size:120%; font-weight:bold;}
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
div.centered {text-align:center;}
h1 {text-align:left;}
h2 {text-align:left;}
h3 {text-align:left;}
.cimage { display:block; max-width: 90%; margin-left: auto; margin-right: auto; }
div.thebody {margin-top:20px; margin-left: 5%; margin-right:5%; max-width:1100px;}
h3 {margin-left:-2%;}
h2 {margin-left:-2%;}
h1 {margin-left:-2%;}
p.left {margin-left:-2%;}
p { margin-bottom:0px; margin-top:20px; }
p.noskip { margin-top:0px; }
ul { margin-top:0px; margin-bottom:0px; margin-left:0px; padding-left:1em; list-style:square;}
hr { margin-bottom:20px; margin-top:20px; }
mjx-container { margin:0px !important; }
</style>
</head>

<body>
END

if ($allatonce == 0) {
print $out <<END;
<script>
function doenter() {
  var rect = \$("#enddiv")[0].getBoundingClientRect();

  if(rect.top <= 0) {
    \$elt = \$( ".content:hidden" ).first();
    \$elt.fadeIn( "slow" );
    \$elt[0].scrollIntoView({ behavior: "smooth", block: "start" });
  } else if(rect.top <= (window.innerHeight || document.documentElement.clientHeight) * 0.8) {
    \$elt = \$( ".content:hidden" ).first();
    \$elt.fadeIn( "slow" );
  } else {
    window.scrollBy({ 
      top: 120, // could be negative value
      left: 0, 
      behavior: 'smooth' 
    });
  }
}
\$( document.body ).keydown(function( event ) {
  if (event.key == "j") {
    \$( ".content:hidden" ).first().fadeIn( "slow" );
  } else if ( event.key == "k" ) {
    \$( ".content:visible" ).last().fadeOut( "slow" );
  } else if (event.key == "J") {
    \$elt = \$( ".content:hidden" ).first();
    \$elt.fadeIn( "slow" );
    \$elt[0].scrollIntoView({ behavior: "smooth", block: "start" });
  } else if (event.key == "n" || event.key == "Enter") {
    doenter();
  } else if (event.key == "K"  || event.key == "Backspace") {
    \$( ".content:visible" ).last().fadeOut( "slow" );
    \$("#enddiv")[0].scrollIntoView({ behavior: "smooth", block: "end" });
  } else if ( event.key == "e") {
    \$("#enddiv")[0].scrollIntoView({ behavior: "smooth", block: "end" });
  }
});
</script>
END
}

print $out <<END;
<div class=thebody>
END

print $out $outstr;

print $out <<END;

<div id="enddiv">&nbsp;</div>
<div style="height:6in;"></div>

</div>

</body>
</html>
END

close ($in); 
close ($out); 

print "done\n";
