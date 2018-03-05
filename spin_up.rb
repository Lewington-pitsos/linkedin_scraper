require 'logger'
require 'watir'

require_relative './rubyscripts/crawler'

logger = Logger.new 'scrape.log'
br = Watir::Browser.new :firefox
crawler = Crawler.new(logger, br)

alec_welby = "https://www.linkedin.com/in/alec-webley-2b900531/"

crawler.login

logger.debug "going to Alex Welby's profile"
br.goto(alec_welby)

crawler.gather_data

BR = br

logger.debug "scrape finished sucessfully\n\n"
