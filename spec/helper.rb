require 'puma'
require 'redis'
require 'watir'

require 'rspec/power_assert'
RSpec::PowerAssert.example_assertion_alias :assert
RSpec::PowerAssert.example_group_assertion_alias :assert

require 'fileutils'
DIR = "/tmp/sso.#{$$}.test"
FileUtils.mkdir_p DIR


TEST_APP_URL = 'http://127.0.0.1:8080'
TEST_APP_PORT = 8080
AUTH_SERVER_URL = 'http://127.0.0.1:8081'
AUTH_SERVER_PORT = 8081

require_relative 'auth_server'
AUTH_SERVER = AuthServer.new

def start_puma port, app, host = '127.0.0.1'
  server = Puma::Server.new app
  server.add_tcp_listener host, port
  server.run
end

RSpec.configure do |config|
  config.before :suite do |example|
    $sessions_pid = spawn "redis-server --unixsocket #{DIR}/sessions.sock --port 0 --dir #{DIR}"
    $tickets_pid = spawn "redis-server --unixsocket #{DIR}/tickets.sock --port 0 --dir #{DIR}"
    $tokens_pid = spawn "redis-server --unixsocket #{DIR}/tokens.sock --port 0 --dir #{DIR}"

    $sessions = Redis.new path: "#{DIR}/sessions.sock"
    $tickets = Redis.new path: "#{DIR}/tickets.sock"
    $tokens = Redis.new path: "#{DIR}/tokens.sock"

    $test_app_pid = fork do
      require_relative 'test_app'
      start_puma TEST_APP_PORT, TestApp.new
      sleep
    end

    start_puma AUTH_SERVER_PORT, AuthServer.new
  end

  config.after :suite do |example|
    pids = [$sessions_pid, $tickets_pid, $tokens_pid, $test_app_pid]
    pids.each { |pid| `kill #{pid}` }
  end
end
