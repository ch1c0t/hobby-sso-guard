Gem::Specification.new do |g|
  g.name    = 'hobby-sso-guard'
  g.files   = `git ls-files`.split($/)
  g.version = '0.0.0'
  g.summary = 'A Rack middleware for SSO(single sign-on).'
  g.authors = ['Anatoly Chernow']

  g.add_dependency 'hobby'
end
