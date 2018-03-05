module Setup
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
end
