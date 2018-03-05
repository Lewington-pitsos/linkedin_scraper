module Navigating
  def first_url
    # retrieves the last 10 urls logged and returns one at random
    # if there are no urls at all, it returns a pre-selected url
    candidates = @archivist.get_recent_employee_urls

    if candidates.length > 0
      URI.unescape(candidates[rand(candidates.length)], "'")
    else
      'https://www.linkedin.com/in/clairetcondro/'
    end
  end
  
  def visit_profile
    # locates all the profile links on the current profile
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

end
