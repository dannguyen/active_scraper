# ActiveScraper

ActiveScraper is meant to simplify the caching of remote data by storing data objects, such as downloaded webpages, as ActiveRecord database objects for future querying. It is a [Rails Engine](http://guides.rubyonrails.org/engines.html) that you can mount on to an existing Rails app.

This library is poorly named because it's not really a web-scraping framework. It's just a strategy for dealing cached content that you've downloaded from the web, which frequently for me consists of webpages from which I'm trying to extract data.

Think of it as [VCR](https://github.com/vcr/vcr), but instead of being used for testing, it's used in the prototyping of data collection.


### Proposed use case

Here's a common situation I find myself in:

I want to download all of the U.S. Supreme Court's opinions, at least the ones posted on supremecourt.gov. That means spidering the [Opinions index page](http://www.supremecourt.gov/opinions/opinions.aspx) and then downloading each of the PDF links, such as this one for [VANCE v. BALL STATE UNIVERSITY](http://www.supremecourt.gov/opinions/12pdf/11-556_11o2.pdf).

This is a trivial scraping exercise, but the problem for me and my OCD is...where do I put these files? Because generally I don't know what I want to do with this raw "data", but I do like getting the scraping out of the way so I don't have to revisit the source website during the development of a project. But then I spend all this time setting up a "datastore" directory, pointing to it in a config file, ignoring it in `gitignore` so I don't dump 500MB of raw HTML into the repo, and rigging a system so that future requests for the webpages hits the `datastore` cache, which requires coming up a naming system so that URLs map to something on the file system.

And then that's usually when my interest in data exploration ends and I go back to reading Twitter.

__But with ActiveScraper__, I have a set of simple methods to consistently normalize and store Web requests in a database. 

So instead of coming up with a naming system in which:

    http://example.com/path/index.html?q=hello&name=world

&ndash; maps to:

    /Hard Drive/app/datastore/http%3A%2F%2Fexample.com/path/index.html/q%3Dhello%26name%3Dworld

&ndash; with __ActiveScraper__, I know that the following calls:

```ruby
ActiveScraper.get('http://example.com/path/index.html?q=hello&name=world')
ActiveScraper.get('http://example.com/path/index.html?&q=hello&name=world')
ActiveScraper.get('http://example.com/path/index.html?name=world&q=hello')
ActiveScraper.get('http://EXAMPLE.COM/path/index.html?q=hello&name=world')
```

&ndash; will all fetch the same cached data response, unless I manually trigger a refresh from the data source:

```ruby
ActiveScraper.get('http://example.com/path/index.html?query=hello&name=world', expires: 5.days.ago)

# Note: this is not implemented yet, as of version 0.0.1
```

And for cases in which the query parameters are things that are inconsequential to the actual response, or, that I don't want stored as plaintext:

```ruby
ActiveScraper.get('http://api.example.com/apples/description?user=bob&key=1234', obfuscate_query: [:key, :user] )
ActiveScraper.get('http://api.example.com/apples/description?user=dan&key=555', obfuscate_query: [:key, :user])
```

Both of the above requests will be normalized to one canonical URI:
    
    http://api.example.com/apples/description?user=__OMIT__&key=__OMIT__



### Why ActiveRecord?

So why not use the far more mature and better-designed [VCR library](https://github.com/vcr/vcr), which, besides being better, doesn't depend on the cruft of ActiveRecord storage? Good question! Though I'm sure you could jury-rig VCR to handle your data requests, there's not much of an API for customizing the freshness of cached data. And at least with a database, you have some flexibility in queries, such as being able to count how many requests you've made to `example.com` that had the particular endpoint of `/v1/data/widgets/*`.

On the other hand, an actual __document store__, through something like [Mongoid](http://mongoid.org/en/mongoid/index.html), is obviously the logical data store. But I don't make many apps using Mongo, so ActiveRecord it is.



### Sample usage

```ruby
resp = ActiveScraper.get("http://www.supremecourt.gov/opinions/slipopinions.aspx?Term=12")

# Now download each PDF
resp.parsed_body.search("table.datatables tr td:nth-child(4) a").each do |a|
    next if a['href'].nil?
    link = "http://www.supremecourt.gov/opinions/" + a['href']
    puts "Downloading #{link}..."
    ActiveScraper.get(link)
    sleep 0.5
end
```

The result of this is that your Rails application will have a `ActiveScraper::CachedResponse` for each of the PDF and HTML files collected. There will also be a corresponding `ActiveScraper::CachedRequest` which keeps a normalized version of the request used to get that response.

Every subsequent request for these URLs will fetch from your ActiveRecord collection as opposed to revisiting the website.



### Status

As of Version 0.0.1...I would not actually use this for anything but the most basic and common kinds of GET requests.