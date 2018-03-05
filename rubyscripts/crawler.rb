#
require_relative './crawler/info_gathering'
require_relative './crawler/setup'
require_relative './archivist'

class Crawler
  include InfoGathering
  include Setup

  attr_accessor :logger, :br, :archivist, :employer_id, :scrapes_needed, :scrapes

  @@login_page = 'https://www.linkedin.com/?originalSubdomain=au'

  def initialize(logger, br, scrapes_needed)
    @logger = logger
    @br = br
    @archivist = Archivist.new

    @scrapes_needed = scrapes_needed
    @scrapes = 0

    logger.debug "Starting new scrape"
    br.goto(@@login_page)
  end

  def scrape
    login
    @br.goto(first_url)
    @logger.debug("beginning scrape at #{@br.url}")
    gather_employee_info
  end

  def goto_next_person
    # gathers all the "people also viwed" profiles into a collection, selects a random profile, and navigates to it
    # triggers the gathering of info for that new profile

    if @scrapes < @scrapes_needed
      logger.debug "finding next profile..."
      visit_profile

      sleep 3
      gather_employee_info
    else
      @logger.debug "scrape finished successfully\n\n\n\n"
    end

  end

  def visit_profile
    # locates all the profile links,
    # if there are any, selects one at random, and performs a javascript click action on it
    # otherwise, navigates back one profile and tries again
    profiles = @br.elements(:class, ["name", "actor-name"]).length
    @logger.debug("number of associated profiles: #{profiles}")
    if profiles > 0
      @br.execute_script("document.getElementsByClassName('name actor-name')[#{rand(profiles)}].click()")
    else
      @br.goto(first_url)
      sleep 3
      visit_profile
    end
  end

  def gather_employee_info
    # records the info for the current profile's employee
    # if the employee has not already been recorded, their employer's info is recorded, their info is recorded, we add to the number of succesfull scrapes and we move on to the next employee
    # otherwise we just move to next employee without recording anything
    info = employee_info
    employer_link = @br.element(:class, "pv-entity__secondary-title")

    if !@archivist.person_already_recorded(info) && employer_link.exists?
      record_profile_info(info, employer_link)
    else
      @logger.info("already scraped #{@br.url}")
    end

    sleep(3)
    @logger.debug("moving to next employee\n\n")
    goto_next_person
  end

  def record_profile_info(info, employer_link)
    # gathers and records employer info
    # returns to employee page, and records the (passed in) employee info
    gather_employer_info(employer_link)
    @br.back
    @logger.debug("inserting employee info...")
    record_employee_info(info)
  end

  def record_employee_info(info)
    # adds an employer_id to the passed in info hash, saves it to the employee relation and records that another profile has been successfully scraped
    info[:employer_id] = @employer_id.to_i
    @archivist.insert_employee(info)
    @scrapes += 1
  end

  def gather_employer_info(employer_link)
    # navigates to the current employer of the employee profile we're on (passed in as a Watir::HTMLElement), gathers its profile info and makes a database entry
    employer_name = employer_link.text
    @logger.debug("navigating to employer page for #{employer_name}")
    employer_link.click()

    sleep 2

    info = get_employer_info(employer_name)
    record_employer_info(info)
  end

  def record_employer_info(info)
    # records the passed in info hash to the infobase, keeps track of that employer's id and finally returns to the employee's page
    @logger.debug("inserting employer info...")
    @archivist.record_employer(info)
    @employer_id = @archivist.get_employer(info[:name])
    @logger.debug(@archivist.get_employer(info[:name]))
  end
end
