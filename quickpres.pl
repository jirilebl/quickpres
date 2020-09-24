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

open(my $in,'<', "pres.prs") or die $!; 
open(my $out, '>' ,"pres.html") or die $!; 

print $out <<END;
<!doctype html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Presentation</title>
<link rel="stylesheet" type="text/css" href="style.css"> 
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
span.smaller {font-size:80%;}
span.tiny {font-size:60%;}
span.larger {font-size:120%;}
span.largerbold {font-size:120%; font-weight:bold;}
span.tt {font-family: Courier, "Courier New", monospace;}
h1 {font-size:180%; font-weight:bold;}
h2 {font-size:120%; font-weight:bold;}
h3 {font-size:100%; font-weight:bold;}
ul {margin-left:0px; padding-left:1em; list-style:square;}
body { 
	font-family: Tex Gyre Pagella, Palatino, URW Palladio L, Palatino Linotype, Palatino LT STD, Book Antiqua, Georgia, serif;
        line-height: 1.5;
	font-size: 220%;
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
\@media screen {
 div.thebody {margin-top:20px; margin-left: 5%; margin-right:5%; max-width:1100px;}
 h3 {margin-left:-2%;}
 h2 {margin-left:-2%;}
 h1 {margin-left:-2%;}
 p.left {margin-left:-2%;}
}
</style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
MathJax = {
  tex: {
    inlineMath: [['\$','\$'],['\\\\(','\\\\)']]
  }
};
</script>
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script> 
<script id="MathJax-script" async 
 src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js"> 
</script> 
</head>

<body>
END

if ($allatonce == 0) {
print $out <<END;
<script>
\$( document.body ).click(function() {
  \$( ".content:hidden" ).first().fadeIn( "slow" );
});
\$( document.body ).keydown(function( event ) {
  if (event.which == 74 || event.which == 13) {
    \$( ".content:hidden" ).first().fadeIn( "slow" );
  } else if ( event.which == 8  || event.which == 75) {
    \$( ".content:visible" ).last().fadeOut( "slow" );
  }
});
</script>
END
}

print $out <<END;
<div class=thebody>
END

my $indiv = 0;
my $dopar = 0;

# No \input file reading here (FIXME?)
while($line = <$in>)
{
	chomp($line);
	$line =~ s/^\s+//;
	$line =~ s/\s+$//;
	if ($line =~ s/^###\s*//) {
		print $out "<h3>$line</h3>\n";
	} elsif ($line =~ s/^##\s*//) {
		print $out "<h2>$line</h2>\n";
	} elsif ($line =~ s/^#\s*//) {
		print $out "<h1>$line</h1>\n";
	} elsif ($line =~ m/^$/) {
		$dopar = 1;
	} elsif ($line =~ m/^\.E$/) {
		print $out "<div style=\"height:2in;\"></div>\n";
	} elsif ($line =~ m/^\.D$/) {
		if ($indiv == 1) { 
			print $out "</div>\n";
		}
		if ($allatonce == 1) {
			print $out "<div class=\"content\">\n";
		} else {
			print $out "<div class=\"content\" style=\"display:none;\">\n";
		}
		$indiv = 1;
	} else {
		if ($dopar == 1) {
			print $out "<p>\n";
		}
		$dopar = 0;
		print $out "$line\n";
	}
}

if ($indiv == 1) { 
	print $out "</div>\n";
}

print $out <<END;

<div style="height:10in;"></div>

</div>

</body>
</html>
END

close ($in); 
close ($out); 

print "done\n";
