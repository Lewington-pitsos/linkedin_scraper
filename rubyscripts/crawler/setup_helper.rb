module SetupHelper
  @@login_page = 'https://www.linkedin.com/?originalSubdomain=au'

  def login
    @logger.debug "Starting new scrape"
    @br.goto(@@login_page)
    @logger.debug "Starting login process"
    # fills the email and password fields with some text and clicks the login button
    # once this is finished, we should have logged into this Linkedin Account

    email = @br.text_field(:id, "login-email")
    email.set("idof@live.com.au")

    pass = @br.text_field(:id, "login-password")
    pass.set("q1as1z2")

    @br.element(:id, "login-submit").click()
  end

  def rescue_scrape
    # I'm sure thare are numberless obscure edge cases I haven't accounted for, so rather than having any one of those sink my whole scrape I thought I'd include a catch-all
    # that said, once we hit 30 failures and still haven't reached our scrapes_needed target, something systemic is probably afoot and we're going to terminate the whole kitten kaboodle
    @fails += 1
    if @fails < 30
      @logger.warn("OOPS Something went terribly wrong on #{@br.url}. Commencing scrape #{@fails}...\n\n\n")
      new_scrape
    else
      @logger.fatal("This failed 30 times, probably best to call it quits. Terminating Scrape")
    end
  end
end
