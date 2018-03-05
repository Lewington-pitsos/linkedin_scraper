require_relative './archivist'

class Crawler

  @@login_page = 'https://www.linkedin.com/?originalSubdomain=au'

  def initialize(logger, br)
    @logger = logger
    @br = br
    @archivist = Archivist.new

    logger.debug "Starting new scrape"
    br.goto(@@login_page)
  end

  def login
    @logger.debug "login process starting"
    # fills the email and password fields with some text and clicks the login button
    # once this is finished, we should have logged into this Linkedin Account

    email = @br.text_field(:id, "login-email")
    email.set("idof@live.com.au")

    pass = @br.text_field(:id, "login-password")
    pass.set("q1as1z2")

    @br.element(:id, "login-submit").click()
  end

  def goto_next_person
    logger.debug "finding next profile..."
    # gathers all the "people also viwed" profiles into a collection, selects a random profile, and navigates to it
    people = @br.elements(:class, ["name", "actor-name"])

    random = people[rand(people.length)]

  end

  def gather_data

  end

  def get_employer_info
    # navigates to the current employer of the employee profile we're on, gathers its profile data and makes a database entry
    # records that entry in the database and finally returns to the employee's page
    goto_employer
    data = employer_data
    puts data

    @archivist.record_employer(data)
    @br.back
  end

  def employer_data
    # expects to be run when on an employer's profile
    # returns all the data relevent to that employer in a hash
    @logger.debug("gathering data from: #{@br.url}")
    employer_info =  {}

    name = @br.element(:class, "org-top-card-module__name").text
    employer_info[:name] = name

    url = @br.url
    employer_info[:url] = url

    website = @br.element(:class, "org-about-company-module__company-page-url").text
    employer_info[:website] = website

    location = @br.element(:class, "org-about-company-module__headquarters").text
    employer_info[:location] = location

    size = @br.element(:class, "org-about-company-module__company-staff-count-range").text
    employer_info[:size] = size

    employer_info
  end

  def goto_employer
    # finds the link for the current empoyer of the current profile, follows it and then clicks on the "show more" button to reveal full profile details
    current_employer = @br.element(:class, "pv-entity__secondary-title")
    @logger.debug("navigating to employer page for #{current_employer.text}")
    current_employer.click()
    @br.element(:id, "org-about-company-module__show-details-btn").click()
    # this does not take effect immediately
    sleep 3
  end

end
