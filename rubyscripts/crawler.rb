require_relative './archivist'

class Crawler

  attr_accessor :logger, :br, :archivist, :employer_id

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
    # records the data for the current profile's employee
    # if the employee has not already been recorded, their employer's data is recorded, their data is recorded and we move on to the next employee
    # otherwise we just move on without recording anything
    data = employee_data

    unless @archivist.person_already_recorded(data)
      get_employer_info
      @logger.debug("inserting employee data...")
      @archivist.insert_employee(data)
    else
      @logger.debug("already scraped #{@br.url}")
    end

    @logger.debug("moving to next employee")
  end

  def employee_data
    # gathers the relevent profile data from the page into a hash
    # adds the most recently recorded employer id
    @logger.debug("gathering data from: #{@br.url}")

    employee_info = {}

    url = @br.url
    employee_info[:url] = url

    get_employee_name(employee_info)

    current_job = @br.element(:class, "pv-top-card-section__headline").text
    employee_info[:current_job] = current_job

    location = @br.element(:class, "pv-top-card-section__location").text
    employee_info[:location] = location

    employee_info[:employer_id] = @employer_id

    employee_info
  end

  def get_whole_name
    @br.element(:class, "pv-top-card-section__name").text
  end

  def get_employee_name(info)
    # finds the employee's name on the current page and saves the first and last name components of that name to the passed in info hash.
    # the first name is all the characters up till the first whitespace character
    whole_name = get_whole_name
    first_name = whole_name.match(/^.*?\s/)[0].strip
    last_name = whole_name.match(/\s.*?$/)[0].strip
    info[:first_name] = first_name
    info[:last_name] = last_name
  end

  def get_employer_info
    # navigates to the current employer of the employee profile we're on, gathers its profile data and makes a database entry
    # records that entry in the database, keeps track of that employer's id and finally returns to the employee's page
    goto_employer
    data = employer_data
    @logger.debug("inserting employer data...")
    @archivist.record_employer(data)
    @employer_id = @archivist.get_employer(data[:name])
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
