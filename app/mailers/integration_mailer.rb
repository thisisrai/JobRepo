class IntegrationMailer < ApplicationMailer
  default from: 'contact@coffeejob.io'

  def request_integration(email, message)
    @message = message
    mail(to: 'thisisrailee@gmail.com', subject: 'Company Integration Request') do |format|
      format.text { render plain: "Email: #{email}\nMessage: #{@message}" }
      format.html { render html: "<p>Email: #{email}</p><p>Message: #{@message}</p>".html_safe }
    end
  end
end