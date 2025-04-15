Gem::Specification.new do |s|
    s.name        = "tsf"
    s.version     = "0.1.0"
    s.summary     = "Ruby parser for Trotec's TSF file format."
    s.description = "Ruby parser for Trotec's TSF file format."
    s.authors     = ["Isaac Bonora"]
    s.email       = "isaac@isbonora.com"
    s.files       = Dir["*.{md,txt}", "{lib}/**/*"]
    s.homepage    =
      "https://rubygems.org/gems/tsfrb"
    s.license       = "MIT"

    s.add_runtime_dependency "ruby-vips", "~> 2.1"
    s.required_ruby_version = Gem::Requirement.new(">= 3.1.0")
  end