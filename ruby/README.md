# Requirements

The following packages are installed:

- ruby-full
- openssl
- libssl-dev

# Installation

```Shell
cd wsgup
sudo gem install bundler
bundle config set deployment true
bundle install
```

# Usage

```Shell
$ ruby main.rb
```

or

```Shell
$ chmod a+x main.rb
$ ./main.rb
```