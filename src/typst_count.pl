use 5.38.0;

# Get file content
my @file_list;

if (!defined($ARGV[0])) {
    @file_list = glob "*.typ";
} else {
    @file_list = grep {m/\.typ$/} @ARGV;
}

my $typ = do {
    my $content = '';
    for my $file (@file_list) {
        open(my $fh, '<', $file) or die "Could not open '$file': $!";
        $content .= do { local $/; <$fh> };
        close($fh);
    }
    $content;
};

=head1 Delete inline comments

 // In line comments

=cut

$typ =~ s@(?:(?<!\\)/){2}.*?$@@mg;

=head1 Delete multi-line comments

 /*
    Multi-line comments
 */

=cut

$typ =~ s@/\*.*?\*/@@sg;

=head1 Delete header prefix

 = Level1 title
 == Level2 title
 === Level3 title

Left:

 Level1 title
 Level2 title
 Level3 title

=cut

$typ =~ s/^\s*[=]+\s*//mg;

=head1 Delete set rules, import/include command

 #set text(lang: "de")
 #import emoji: face
 #include "bar.typ"

=cut

$typ =~ s/^\s*#(?:set|import|include)\s+.*//mg;

=head1 Delete show rules

 #show "once?": it => [#it #it]
 #show raw.where(lang: "hex"): r => {
   show "00": set text(gray)
   show "67": highlight.with(fill: yellow)
   show "FF": strong
   
   r
 }

=cut

$typ =~ s/
    ^\s*\#show\s*
    [^{}]+
    (\{(?:[^{}]*|(?-1))\})?
//xmg;

=head1 Delete function definition string and block

 #{
  let a = [from]
  let b = [*world*]
  [hello ]
  a + [ the ] + b
 }

 #let hello(a,b) = {
   [#a+#b]  
 }

=cut

$typ =~ s/
    ^\s*\#(?:let\s+[^{}\n]*)?
    (\{(?:[^{}]*|(?-1))*\})
//xsmg;

=head1 Delete function calling string with body, left text in []

 #figure(
   image("img/fastapi-multicenter-mac-to-port-table.png"),
   caption: [FastAPI Page: MAC to port table]
 )
 
 #hello()[World]
 #emph[Hello]

Then left:

 World
 Hello

=cut

$typ =~ s/
    ^\s*\#
    [^()\n]*
    (\((?:[^()]|(?-1))*\))?
    \[(.*?)\]
/\n$2/mxsg;

=head1 Delete function calling string without body

 #figure(
   image("img/fastapi-multicenter-mac-to-port-table.png"),
   caption: [FastAPI Page: MAC to port table]
 )

 #panic("this is wrong")
 
=cut

$typ =~ s/
    ^\s*\#
    [^()\n]*
    (\((?:[^()]|(?-1))*\))?
//xsmg;

=head1 Merge white space characters

 \n
 \n
 
To:

 \n

=cut

$typ =~ s/^\s*$//mg;

$typ =~ s/[^\S\n]/ /;

my @words = split(/\s+/, $typ);
my $word_count = scalar @words;
print "Word count: $word_count\n";

__END__
