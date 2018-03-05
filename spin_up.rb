require 'logger'
require 'watir'

require_relative './rubyscripts/crawler'

logger = Logger.new 'scrape.log'
logger.debug "Starting new scrape"

crawler = Crawler.new(logger)

alec_welby = "https://www.linkedin.com/in/alec-webley-2b900531/"

br = Watir::Browser.new :firefox
br.goto('https://www.linkedin.com/?originalSubdomain=au')

crawler.login(br, logger)

logger.debug "going to Alex Welby's profile"
br.goto(alec_welby)

BR = br

logger.debug "scrape finished sucessfully"
