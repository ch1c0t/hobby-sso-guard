require 'securerandom'

module Hobby
  module SSO
    class Guard
      # sessions: { session_id => user_id }
      # tickets: { ticket => session_id } should expire quickly(20 seconds or so)
      # tokens: { token => latest_visited_path }
      def initialize app, sessions:, tickets:, tokens:, auth_server:
        @app, @sessions, @tokens = app, sessions, tokens
        @auth_server = auth_server
        @enter_app = Enter.new tickets, tokens
      end

      def call env
        @env = env

        if active_session?
          @app.call env
        else
          if env['PATH_INFO'] == '/enter'
            @enter_app.call env
          else
            redirect_to_auth_server_with_token create_guest_token
          end
        end
      end

      private
        attr_reader :env

        def active_session?
          session = env['rack.session']
          @sessions.exists session[:id]
        end

        def create_guest_token
          token = SecureRandom.urlsafe_base64 64
          env['rack.session'][:guest_token] = token
          @tokens.hset token, 'path', env['PATH_INFO']
          @tokens.hset token, 'query', env['QUERY_STRING']
          token
        end

        def redirect_to_auth_server_with_token token
          location = "#{@auth_server}?service=#{env['HTTP_HOST']}&token=#{token}"
          [302, { 'Location' => location }, []]
        end
    end
  end
end

require_relative 'guard/enter'
