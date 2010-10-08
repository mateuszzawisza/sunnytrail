Gem::Specification.new do |s|
  s.name = 'sunnytrail'
  s.version = '0.0.1.4'
  s.date = '2010-09-13'
  s.authors = ["Mateusz Zawisza"]
  s.email = 'mateusz@applicake.com'
  s.summary = 'Wrapper for Sunnytrail API'
  s.homepage = 'http://github.com/mateuszzawisza/sunnytrail'
  s.description = 'Wrapper for SunnyTrail API'
  s.files = %w{README.rdoc} + Dir['lib/**/*.rb'] + Dir['spec/**/*.rb'] 
  s.add_dependency 'hashie'
  s.add_dependency 'json'
  s.has_rdoc = 'true'
  s.extra_rdoc_files = ['README.rdoc']
end

