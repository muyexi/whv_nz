
## Description
Ruby script to apply for [Working Holiday Visa](https://www.immigration.govt.nz/new-zealand-visas/options/work/thinking-about-coming-to-new-zealand-to-work/working-holiday-visa) from New Zeanland.

## Installation

```sh
$ gem install whv_nz
```

## Usage

```sh
$ whv_nz

Usage: main [options]
-n, --new             Generate config file
-c, --config          Config file path
-p, --production      Use real account
-d, --daemon          In background
-h, --help            Show help info
```

## Config
* title: 1(Mr), 2(Mrs), 3(Ms), 4(Miss), 5(Dr), 6(Other)
* gender: M(Male), F(Female)
* been_before: No/Yes

## Dependency
* [Chrome](https://www.google.com/chrome/)
* [Xvfb](http://elementalselenium.com/tips/38-headless)
* [ChromeDriver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
* (Optional)[Supervisor](http://supervisord.org/)
* (Optional)Config [Mailgun](https://www.mailgun.com/) for email notification
* (Optional)Config [Rollbar](https://rollbar.com/) for error tracking

## Reference
* [Setup a Faraday Proxy](https://evancarmi.com/writing/faraday-proxy/)
