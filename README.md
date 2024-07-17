# wsgup
The *wsgup* (pronounced "what's up") project is an attempt at re-implementating 
[zerotypic's wasg-register.py][wasg-register] in other programming languages.

At the moment, I am targeting a re-implementation in [Go](https://go.dev) and [Rust](https://www.rust-lang.org). 
I am also planning to keep them as command line console program for simplicity as a first attempt.

> [!TIP]  
> The official [Wireless@SGx App][connect-wireless-sg] from [Infocomm Media Development Authority (IMDA)][imda] is
> widely used and supported. Thus, it is *the recommended tool for users looking to register (or re-register) for an account*
> to connect to [Wireless@SG][wireless-sg] public hotspots for free Wi-Fi access in public places across Singapore.
> Supported platforms are **[Windows][windows], [MacOS][macos], [iOS][ios] and Android** ([Google Play][google-play] and
> [Huawei App Gallery][huawei-appgallery]).
>
> On unsupported platforms like Linux, users can turn to the [zerotypic's Python implementation][wasg-register]. It
> is the one widely adopted and used by Linux users.
> 
> In fact, there is no reason to use `wsgup` ever.

This is treated as a personal hobby project to learn new programming languages. Thus, we should note the followings:

> [!NOTE]
> - Nothing should be assumed to be working or suitable for real-world production use
> - I am not accepting pull requests to integrate any enhancements or bugfixes

[wasg-register]: https://github.com/zerotypic/wasg-register
[wireless-sg]: https://www.imda.gov.sg/how-we-can-help/wireless-at-sg
[connect-wireless-sg]: https://www.imda.gov.sg/how-we-can-help/wireless-at-sg/wireless-at-sg-for-consumers
[imda]: https://www.imda.gov.sg/
[windows]: https://www.imda.gov.sg/how-we-can-help/wireless-at-sg/wireless-at-sg-for-consumers
[macos]: https://apps.apple.com/us/app/wireless-sg-new/id1449928544?ls=1&mt=12
[ios]: https://apps.apple.com/us/app/wireless-sg-new/id1449928538?ls=1
[google-play]: https://play.google.com/store/apps/details?id=sg.gov.imda.wsgapp2_android&hl=en&pli=1
[huawei-appgallery]: https://appgallery.huawei.com/app/C107485705?sharePrepath=ag&channelId=IMDA%20Webpage&id=dd9887a5b5f247309c410110a0595f04&s=DAA3256D2A32CFFEBA648B437A2F5EAF7DD776ABCE2B37FFC3A408B6AE3CB109&detailType=0&v=&callType=AGDLINK&installType=0000&shareTo=qrcode

