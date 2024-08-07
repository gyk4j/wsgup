# Requirements

The following packages are installed:

- perl
- build-essential
- gcc
- g++
- make

# Installation

Install globally for all users:

```Shell
$ cd wsgup
$ sudo cpan App::cpanminus
$ sudo cpanm --installdeps .
```

or install for per-user:

```
$ cd wsgup
$ cpan --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
$ cpan App::cpanminus
$ cpanm --installdeps .
```

# Usage

```Shell
$ perl main.pl
```

or

```Shell
$ chmod a+x main.pl
$ ./main.pl
```
