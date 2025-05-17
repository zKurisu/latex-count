# Introduction
Calculate the body word count (general, not very accurate) in latex file (English) using perl code.

# Usage
For all `.tex` file under the current directory:
```sh
$ tree
.
├── 1_introduction.tex
├── 2_theory.tex
├── 3_body.tex
├── 4_simulation.tex
├── 5_conclustion.tex
├── 6_future_work.tex
└── latex_count.pl
$ perl latex_count.pl
Word count: 9979
```

For single file or multi specific files:
```sh
$ perl latex_count.pl 1_introduction.tex 2_theory.tex
Word count: 2778
```

