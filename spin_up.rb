require 'watir'


def login(br)
  email = br.text_field(:id, "login-email")
  email.set("idof@live.com.au")

  pass = br.text_field(:id, "login-password")
  pass.set("q1as1z2")

  br.element(:id, "login-submit").click()
end


BR = Watir::Browser.new :firefox
BR.goto('https://www.linkedin.com/?originalSubdomain=au')

login(BR)
