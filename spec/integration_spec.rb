require_relative 'helper'

describe do
  let(:browser) { Watir::Browser.new }

  context 'when there is no active session' do
    it 'redirects to the auth server' do
      $auth_server_just_returns_HTTP_HOST = true
      browser.goto TEST_APP_URL
      assert { browser.text == '127.0.0.1:8081' }
    end

    after do
      $auth_server_just_returns_HTTP_HOST = false
    end
  end

  context 'when a user tries to /enter' do
    it 'refuses if there is no ticket' do
      browser.goto "#{TEST_APP_URL}/enter"
      assert { browser.text == 'No ticket.' }
    end

    it 'refuses if there is a bad ticket' do
      bad_ticket = SecureRandom.urlsafe_base64 64
      browser.goto "#{TEST_APP_URL}/enter?ticket=#{bad_ticket}"
      assert { browser.text == 'Bad ticket.' }
    end

    context 'when the ticket is valid' do
      it 'sets a session cookie and redirect to an appropriate path' do
        browser.goto "#{TEST_APP_URL}/some_path"
        assert { browser.text == 'some path in test app' }
      end
    end
  end

  after do
    browser.quit
    $sessions.flushall
    $tickets.flushall
    $tokens.flushall
  end
end
