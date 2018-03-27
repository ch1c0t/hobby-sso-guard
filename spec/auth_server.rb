require 'hobby'

class AuthServer
  include Hobby

  get do
    require 'awesome_print'
    ap env
    env
  end
end
