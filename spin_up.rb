require 'logger'

logger = Logger.new 'scrape.log'
logger.debug "Starting new scrape"

require 'watir'

alec_welby = "https://www.linkedin.com/in/alec-webley-2b900531/"

def login(br, logger)
  logger.debug "login process starting"
  # fills the email and password fields with some text and clicks the login button
  # once this is finished, we should have logged into this Linkedin Account

  email = br.text_field(:id, "login-email")
  email.set("idof@live.com.au")

  pass = br.text_field(:id, "login-password")
  pass.set("q1as1z2")

  br.element(:id, "login-submit").click()
end

def goto_next_person(br)
  logger.debug "finding next profile..."
  # gathers all the "people also viwed" profiles into a collection, selects a random profile, and navigates to it
  people = br.elements(:class, ["name", "actor-name"])

  random = people[rand(people.length)]

end

def gather_data(br)

end


br = Watir::Browser.new :firefox
br.goto('https://www.linkedin.com/?originalSubdomain=au')

login(br, logger)

logger.debug "going to Alex Welby's profile"
br.goto(alec_welby)

BR = br

logger.debug "scrape finished sucessfully"
