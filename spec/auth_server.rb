require 'hobby'
require 'awesome_print'

class AuthServer
  include Hobby

  get do
    ap env
    env['SERVER_PORT']
  end
end
