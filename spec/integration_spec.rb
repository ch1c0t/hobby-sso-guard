require_relative 'helper'

describe do
  let(:browser) { Watir::Browser.new }

  context 'when there is no active session' do
    it 'redirects to the auth server' do
      browser.goto TEST_APP_URL
      assert { browser.text == AUTH_SERVER_PORT.to_s }
    end
  end

  context 'when a user tries to /enter' do
    it 'refuses if there is no ticket' do
      browser.goto "#{TEST_APP_URL}/enter"
      assert { browser.text == 'No ticket.' }
    end
  end

  after do
    browser.quit
    $sessions.flushall
    $tickets.flushall
    $tokens.flushall
  end
end
