=begin

Broadly this module contains methods that (a) concern the gathering of data from profile pages and (b) actually contain Watir selectors in order to do that gathering.

=end

module InfoGathering
  def employee_info
    # gathers the relevent profile info from the page into a hash
    # adds the most recently recorded employer id
    @logger.debug("gathering info from: #{@br.url}")

    employee_info = {}

    url = URI.escape(@br.url, "'")
    employee_info[:url] = url

    get_employee_name(employee_info)

    current_job = try_gathering("pv-top-card-section__headline")
    employee_info[:current_job] = current_job

    location = try_gathering("pv-top-card-section__location")
    employee_info[:location] = location

    employee_info
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

  def get_whole_name
    @br.element(:class, "pv-top-card-section__name").text
  end

  def try_gathering(class_list)
    # searches for an element matching the passed in class list, and if it finds it, returns it's text content. Otherwise, returns nil
    if @br.element(:class, class_list).exists?
      URI.escape(@br.element(:class, class_list).text, "'")
    else
      nil
    end
  end

  def get_employer_info(employer_name)
    # checks whether there is an employer title on the page
    # if so, all employer info is gathered, and returned
    # otherwise (because some employers aren't listed) a dummy employer info hash is created with only a name
    if @br.element(:class, "org-top-card-module__name").exists?
      @logger.debug("Employer registered, gathering full employee info")
      @br.element(:id, "org-about-company-module__show-details-btn").click()
      # this does not take effect immediately
      sleep 3
      employer_info
    else
      @logger.warn("Employer not registered, recording dummy employer")
      {name: employer_name}
    end
  end

  def employer_info
    # expects to be run when on an employer's profile
    # returns all the info relevent to that employer in a hash
    @logger.debug("gathering info from: #{@br.url}")
    employer_info =  {}

    name = try_gathering("org-top-card-module__name")
    employer_info[:name] = name

    url = URI.escape(@br.url, "'")
    employer_info[:url] = url

    website = try_gathering("org-about-company-module__company-page-url")
    employer_info[:website] = website

    location = try_gathering("org-about-company-module__headquarters")
    employer_info[:location] = location

    size = try_gathering("org-about-company-module__company-staff-count-range")
    employer_info[:size] = size

    employer_info
  end
end
