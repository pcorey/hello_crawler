# HelloCrawler

This project is a companion to the [Learning to Crawl - Building a Bare Bones Web Crawler with Elixir](#) article. `HelloCrawler` is not intended to be used as an out-of-the-box crawler solution and is most definitely not production ready.

For educational purposes only.

## Instructions

First, clone the `hello_crawler` project onto your machine and `cd` into the new `hello_crawler` directory:

```
git clone https://github.com/pcorey/hello_crawler && cd hello_crawler
```

Fire up an interactive Elixir shell:

```
iex -S mix
```

And try crawling over any page you want:

```elixir
HelloCrawler.get_links("http://www.east5th.co/")
```

The maximum depth of the crawl can be configured by changing the `@max_depth` attribute in the `HelloCrawler` module.
