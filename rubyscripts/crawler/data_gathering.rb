module DataGathering
  def employee_data
    # gathers the relevent profile data from the page into a hash
    # adds the most recently recorded employer id
    @logger.debug("gathering data from: #{@br.url}")

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

  def employer_data
    # expects to be run when on an employer's profile
    # returns all the data relevent to that employer in a hash
    @logger.debug("gathering data from: #{@br.url}")
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
