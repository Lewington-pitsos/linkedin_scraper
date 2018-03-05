=begin

Broadly Crawler has three components:
  Setup

    Triggered once. Gets everything in place for potentially indefinite scrapes by logging on to linkedin and navigating to an innitial profile.

  Gathering Cycle

    The data from this profile is gathered through the DOM and recorded to a database (with the help of an Archivist instance). At the end of this cycle we trigger the Navigatin Cycle. The Gathering Cycle can be cut short if some data is missing (as it invariably will be sometimes).

  Navigating Cycle

    This profile is searched for links to other profiles. If any are found we navigate to one chosen at random. Otherwise we search our current database for past linkes and follow one of those. Once a new profile has been reached we trigger the Gathering cycle.

Recursive calls between the Navigating and Gathering cycles could theoretically continue indefinitly. However Crawler is also passed in a scrapes_needed argument (int), and after that many profiles have been scraped, Crawler considers the scrape a success and terminates everything.


=end


require_relative './crawler/setup_helper'
require_relative './crawler/info_gathering'
require_relative './crawler/navigating'
require_relative './archivist'

class Crawler
  include SetupHelper
  include InfoGathering
  include Navigating

  attr_accessor :logger, :br, :archivist, :employer_id, :scrapes_needed, :scrapes

  # ======== Setup ===========

  def initialize(logger, browser, scrapes_needed)
    @logger = logger
    @br = browser
    @archivist = Archivist.new

    @scrapes_needed = scrapes_needed
    @scrapes = 0

    @fails = 0
  end

  def begin_scraping
    # logs in and triggers a new scrape
    login
    new_scrape
  end

  def new_scrape
    # finds an innitial url and navigates to it
    # starts gather >>> navigate >>> gather recursion
    # if there are ANY errors raised during recursion we rescue the scrape by starting a new one
    @br.goto(first_url)
    @logger.debug("beginning scrape at #{@br.url}")
    begin
      gather_employee_info
    rescue
      rescue_scrape
    end
  end

  # ======== Gathering Cycle ===========

  def gather_employee_info
    # if the employee has not already been recorded and their profile contains a link to their most recent employer, we gather and record all info for that employee and their employer
    # otherwise we just move to next employee without recording anything
    info = employee_info
    employer_link = @br.element(:class, "pv-entity__secondary-title")

    if !@archivist.person_already_recorded(info) && employer_link.exists?
      record_profile_info(info, employer_link)
    else
      @logger.info("#{@br.url} has already been scraped")
    end

    sleep(3)
    @logger.debug("moving to next employee\n\n")
    scrape_next_employee
  end

  def record_profile_info(info, employer_link)
    # gathers and records employer info
    # returns to employee page, and records the (passed in) employee info
    gather_employer_info(employer_link)
    @br.back
    @logger.debug("inserting employee info...")
    record_employee_info(info)
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

  def record_employee_info(info)
    # adds an employer_id to the passed in info hash, saves it to the employee relation and records that another profile has been successfully scraped
    info[:employer_id] = @employer_id.to_i
    @archivist.insert_employee(info)
    @scrapes += 1
  end

  # ======== Navigating Cycle ===========

  def scrape_next_employee
    # gathers all the "people also viwed" profiles into a collection, selects a random profile, and navigates to it
    # triggers the gathering of info for that new profile

    if @scrapes < @scrapes_needed
      scrape_profile
    else
      @logger.debug "scrape finished successfully\n\n\n\n"
    end
  end

  def scrape_profile
    # navigates to the next employee profile and gathers/records it's info
    logger.debug "finding next profile..."
    visit_profile

    sleep 3
    gather_employee_info
  end
end
