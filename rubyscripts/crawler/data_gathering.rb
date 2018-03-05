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
end
