use 5.38.0;

# Get file content
my @file_list;

if (!defined($ARGV[0])) {
    @file_list = glob "*.tex";
} else {
    @file_list = grep {m/\.tex$/} @ARGV;
}

my $tex = do {
    my $content = '';
    for my $file (@file_list) {
        open(my $fh, '<', $file) or die "Could not open '$file': $!";
        $content .= do { local $/; <$fh> };
        close($fh);
    }
    $content;
};

# The content of the cmd is no need
my @content_del_cmd = qw/
documentclass begin end usepackage maketitle centering
graphicspath newcommand newenvironment renewenvironment geometry
hypersetup AtBeginDocument vspace addcontentsline newgeometry
bigskip vfill includegraphics include appendix bibliographystyle
bibliography pagestyle pagenumbering pagebreak listoftables
listoffigures tableofcontents
/;
my $content_del_cmd_str = join "|", @content_del_cmd;
my $content_del_cmd_reg = qr/(?:$content_del_cmd_str)/;

# Delete env
my @env_del_cmd = qw/
declaration table figure equation
/;
my $env_del_cmd_str = join "|", @env_del_cmd;
my $env_del_cmd_reg = qr/(?:$env_del_cmd_str)/;

# Delete comments
$tex =~ s/(?<!\\)%.*?$//gm;

# Delete env like:
# \begin{table}[h!]
#   ...
# \end{table}
$tex =~ s/\\begin\{($env_del_cmd_reg\*?)\}.*?\\end\{\1\}//sg;

# Delete command like: \documentclass{article}, \maketitle, the content is not related to body
$tex =~ s/\\$content_del_cmd_reg(?:\*)?(?:\[.*?\])?(?:\{.*?$)?//smg; 

# Delete command like: \title{xxx}, \author{xxx} the content is part of body
$tex =~ s/\\\w+\*?\{(.*?)\}/$1/g; 

# Delete bare parameter settings, like: paper=a4paper
$tex =~ s/.*?=.*?,\s*$//mg;

# Delete bare double line
$tex =~ s/^\s*$//mg;

# Merge whitespace characters
$tex =~ s/[^\S\n]/ /g;

my @words = split(/\s+/, $tex);
my $word_count = scalar @words;
print "Word count: $word_count\n";
# print "Clean text:\n$tex\n\n";
