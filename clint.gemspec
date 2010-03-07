Gem::Specification.new do |s|
  s.name = "clint"
  s.version = "0.1.4"
  s.date = "2010-03-07"
  s.authors = ["Richard Crowley"]
  s.email = "r@rcrowley.org"
  s.summary = "command line argument parser"
  s.homepage = "http://github.com/rcrowley/clint.git"
  s.description = File.read(File.join(File.dirname(__FILE__), "README.md"))
  s.files = [
    "lib/clint.rb",
    "man/man7/clint.7.gz",
  ]
end
