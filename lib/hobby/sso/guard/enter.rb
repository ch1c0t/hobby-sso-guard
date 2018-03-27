require 'hobby'

class Hobby::SSO::Guard
  class Enter
    include Hobby

    def initialize tickets, tokens
      @tickets, @tokens = tickets, tokens
    end

    get '/enter' do
      if ticket = request.params['ticket']
        if session_id = @tickets.get(ticket)
          session[:id] = session_id
          redirect_to_latest_visited_path_or_root
        else
          response.status = 403
          'Bad ticket.'
        end
      else
        response.status = 403
        'No ticket.'
      end
    end

    def session
      env['rack.session']
    end

    def redirect_to_latest_visited_path_or_root
      token = session[:guest_token]
      if @tokens.exists token
        path = @tokens.hget token, 'path'
        query = @tokens.hget token, 'query'
        response.redirect "#{path}?#{query}"
      else
        response.redirect '/'
      end
    end
  end
end
