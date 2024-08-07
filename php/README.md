# Requirements

The following packages are installed:

- php
- php-cli

# Installation

None. However, on Windows, you may need to edit `php.ini` to enable OpenSSL 
extension for `openssl_decrypt` function to work.

Use `php --ini` to locate the active configuration file in use, and uncomment:

```
extension=openssl
```

On Ubuntu, `openssl_decrypt` function works even if the *openssl* extension is
disabled.

# Usage

```Shell
$ php index.php
```

or

```Shell
$ chmod a+x index.php
$ ./index.php
```