require_relative 'helper'

describe do
  it do
    browser = Watir::Browser.new
    browser.goto TEST_APP_URL
    sleep 1
    assert { browser.text == '8081' }
  end

  after do
    $sessions.flushall
    $tickets.flushall
    $tokens.flushall
  end
end
