require 'securerandom'

module Hobby
  module SSO
    class Guard
      # sessions: { session_id => user_id }
      # tickets: { ticket => session_id } should expire quickly(20 seconds or so)
      # guest_tokens: { token => latest_visited_path }
      def initialize app, sessions:, tickets:, guest_tokens:, auth_server:
        @app, @sessions, @guest_tokens = app, sessions, guest_tokens
        @auth_server = auth_server
        @enter_app = Enter.new tickets, guest_tokens
      end

      def call env
        if active_session? env
          @app.call env
        else
          if env['PATH_INFO'] == '/enter'
            @enter_app.call env
          else
            create_guest_token env
            [302, { 'Location' => @auth_server }, []]
          end
        end
      end

      private
        def active_session? env
          session = env['rack.session']
          @sessions.exists session[:id]
        end

        def create_guest_token env
          token = SecureRandom.uuid
          env['rack.session'][:guest_token] = token
          @guest_tokens.hset token, 'path', env['PATH_INFO']
          @guest_tokens.hset token, 'query', env['QUERY_STRING']
        end
    end
  end
end

require_relative 'guard/enter'
