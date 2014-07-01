$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acl_system2"
  s.version     = '0.2.0'
  s.authors     = ["Ezra Zygmuntowicz", "Michal Ochman"]
  s.email       = ["ocherek@gmail.com"]
  s.homepage    = "https://github.com/ocher/acl_system2"
  s.summary     = "An access control gem"
  s.description = "An access control gem. A flexible declarative way of protecting your various controller actions using roles."

  s.files = Dir["{lib}/**/*"]
  s.test_files = Dir["test/**/*"]
end
