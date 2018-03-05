require 'logger'
require 'watir'

require_relative './rubyscripts/crawler'

logger = Logger.new 'scrape.log'
br = Watir::Browser.new :firefox
crawler = Crawler.new(logger, br, 8)
crawler.scrape

BR = br
