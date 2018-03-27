require 'hobby'
require 'hobby/sso/guard'

class TestApp
  include Hobby

  use Rack::Session::Cookie, secret: SecureRandom.hex(64)
  use Hobby::SSO::Guard, auth_server: AUTH_SERVER_URL,
    sessions: $sessions, tickets: $tickets, guest_tokens: $tokens

  get do
    'test app root'
  end

  get '/some_path' do
    'some path in test app'
  end
end
