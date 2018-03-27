require 'hobby'
require 'awesome_print'

class AuthServer
  include Hobby

  get do
    if $auth_server_just_returns_HTTP_HOST
      ap env
      env['HTTP_HOST']
    else
      session, ticket = random, random
      $sessions.set session, 'some_user_id'
      $tickets.set ticket, session
      
      response.status = 302
      response.redirect "#{TEST_APP_URL}/enter?ticket=#{ticket}"
    end
  end

  def random
    SecureRandom.urlsafe_base64 64
  end
end
