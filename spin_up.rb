require 'logger'
require 'watir'

require_relative './rubyscripts/crawler'

logger = Logger.new 'scrape.log'
br = Watir::Browser.new :firefox
crawler = Crawler.new(logger, br, 4)

alec_welby = "https://www.linkedin.com/in/alec-webley-2b900531/"

crawler.login

logger.debug "going to Alex Welby's profile"
br.goto(alec_welby)

BR = br

crawler.gather_data
