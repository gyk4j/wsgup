[![Linux CI](https://github.com/gyk4j/wsgup/actions/workflows/linux.yml/badge.svg)](https://github.com/gyk4j/wsgup/actions/workflows/linux.yml)
[![Windows CI](https://github.com/gyk4j/wsgup/actions/workflows/windows.yml/badge.svg)](https://github.com/gyk4j/wsgup/actions/workflows/windows.yml)

# wsgup: An Introduction

*wsgup* (pronounced "what's up") is a bundle of command line console programs
for testing Wireless@SG credential decryption and recovery upon account 
registration as a user of the free public hotspot network. These programs are 
functionally identical except rewritten in different programmming languages.

Each program demonstrates:

- string manipulation (e.g. formatting, interpolation, concatenation)
- file reading
- JSON parsing
- data encoding and conversion (binary, hex and UTF-8)
- AES-CCM decryption

They are available in various programming languages as short programs in 100 to 
200 lines. Implementation languages include: C, C#, Dart, Go, Java, JavaScript 
(Node.js), Kotlin, Perl, PHP, Python, Ruby, Rust, Swift and Visual Basic.NET.

# Preface

The purpose of *wsgup* is simply to explore the ease, challenges and 
differences in implementing an identical program in different programming 
languages. Whenever possible, I have tried to do a line-by-line porting to 
mostly keep these implementations identical and easier for tracing and 
comparison, except when the different language syntax or library APIs do not 
permit I may write with an extra line or two with greater verbosity.

This is treated as a personal hobby project to learn new programming languages. 

Thus, we should note the followings:

> [!NOTE]
> - Nothing should be assumed to be working or suitable for real-world 
> production use
> - I am not accepting pull requests to integrate any enhancements or bugfixes
>
> As a matter of fact, it is the first time experience with writing a working
> program in [Go](https://go.dev), [Rust](https://www.rust-lang.org) and 
> [Ruby](https://www.ruby-lang.org). So I may miss out on language constructs
> or shorthands that could have kept the code more concise.

# Background of Wireless@SG

Wireless@SG is a free nation-wide Wi-Fi hotspot network in Singapore, offering 
public access to Wi-Fi network since 2005. Users wanting to use this free Wi-Fi 
hotspot network are required to register using their identity and mobile phone 
number. This is done via the officially provided 
[Wireless@SGx App][connect-wireless-sg]. 

# wasg-register.py

A (possibly cybersecurity professional) zerotypic has analyzed it including the 
network traffic from the user registration API. He/she has also described 
his/her findings in a [blog post][making-wireless-sgx-work-on-linux]. In it, 
he/she describes the sequence of network requests, data sent/received, and the 
cryptographic algorithm and settings.

Based on the information provided in his blog post, and after studying his/her 
[wasg-register.py][wasg-register] tool, a very small subset of codes relevant
to the decryption process is then extracted and re-implemented in `wsgup`.

> [!TIP]  
> The official [Wireless@SGx App][connect-wireless-sg] from 
> [Infocomm Media Development Authority (IMDA)][imda] is widely used and 
> supported. Thus, it is *the recommended tool for users looking to register 
> (or re-register) for an account* to connect to [Wireless@SG][wireless-sg] 
> public hotspots for free Wi-Fi access in public places across Singapore.
> Supported platforms are **[Windows][windows], [MacOS][macos], [iOS][ios] and 
> Android** ([Google Play][google-play] and 
> [Huawei App Gallery][huawei-appgallery]).
>
> On unsupported platforms like Linux, users can turn to the 
> [zerotypic's Python implementation][wasg-register]. It is the one widely 
> adopted and used by Linux users.
> 
> In fact, there is no reason to use `wsgup` ever.

# What `wsgup` does

The sole purpose is to try out credentials decryption and recovery from AES-CCM
encrypted data as returned by the Wireless@SG account registration API in 
various popular programming languages, runtimes and libraries.

These programs focus solely on the AES-CCM decryption of the generated 
credentials. Encryption done by the API in the backend is not covered.

# What `wsgup` does not do

Simplicity is the core tenet for these small console CLI programs. They are not
designed to facilitate the entire user account registration process; they only 
simulate the decryption of generated credentials based on the cryptographic
information known thus far. 

# How does `wsgup` work?

What these programs do is to simply read in test data saved in 2 JSON files:

1. `shared/register.json`
2. `shared/testdata.json`

These two required files are *NOT* available out-of-the-box.

## Method 1: Use randomly-generated test data

A Node.js-based tool is provided in `shared` folder which must be run to 
generate these 2 files sample containing random test data.

```
$ cd shared
$ ls
README.md  main.js
$ node main.js
$ ls
README.md  main.js  register.json  testdata.json
$ cd ..
```

## Method 2: Capture and use real data

You may also verify the programs against real-world data. For this, you have to 
intercept and capture their own test data using a Man-in-the-Middle HTTPS 
proxy or network sniffing tools like *Wireshark*.

# Usage

You can then invoke the various test programs. For example:

```
$ cd bin/c
$ ./wsgup
$ cd ../dart
$ ./wsgup
$ cd ../go
$ ./wsgup
$ cd ../rust
$ ./wsgup
```

> [!NOTE]
> Some of these programs require some installation of dependencies before use,
> especially those in interpreted scripting languages.  
> Read their respective *README.md* for specific instructions on how to install
> their required libraries and components.

[making-wireless-sgx-work-on-linux]: https://zerotypic.medium.com/making-wireless-sgx-work-on-linux-92216c66fdb7
[wasg-register]: https://github.com/zerotypic/wasg-register
[wireless-sg]: https://www.imda.gov.sg/how-we-can-help/wireless-at-sg
[connect-wireless-sg]: https://www.imda.gov.sg/how-we-can-help/wireless-at-sg/wireless-at-sg-for-consumers
[imda]: https://www.imda.gov.sg/
[windows]: https://www.imda.gov.sg/how-we-can-help/wireless-at-sg/wireless-at-sg-for-consumers
[macos]: https://apps.apple.com/us/app/wireless-sg-new/id1449928544?ls=1&mt=12
[ios]: https://apps.apple.com/us/app/wireless-sg-new/id1449928538?ls=1
[google-play]: https://play.google.com/store/apps/details?id=sg.gov.imda.wsgapp2_android&hl=en&pli=1
[huawei-appgallery]: https://appgallery.huawei.com/app/C107485705?sharePrepath=ag&channelId=IMDA%20Webpage&id=dd9887a5b5f247309c410110a0595f04&s=DAA3256D2A32CFFEBA648B437A2F5EAF7DD776ABCE2B37FFC3A408B6AE3CB109&detailType=0&v=&callType=AGDLINK&installType=0000&shareTo=qrcode

