# -*- encoding: utf-8 -*-
# stub: faraday-multipart 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday-multipart".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/lostisland/faraday-multipart/issues", "changelog_uri" => "https://github.com/lostisland/faraday-multipart/blob/v1.1.1/CHANGELOG.md", "documentation_uri" => "http://www.rubydoc.info/gems/faraday-multipart/1.1.1", "homepage_uri" => "https://github.com/lostisland/faraday-multipart", "source_code_uri" => "https://github.com/lostisland/faraday-multipart", "wiki_uri" => "https://github.com/lostisland/faraday-multipart/wiki" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mattia Giuffrida".freeze]
  s.date = "1980-01-02"
  s.description = "Perform multipart-post requests using Faraday.\n".freeze
  s.email = ["giuffrida.mattia@gmail.com".freeze]
  s.homepage = "https://github.com/lostisland/faraday-multipart".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new([">= 2.4".freeze, "< 4".freeze])
  s.rubygems_version = "3.0.3.1".freeze
  s.summary = "Perform multipart-post requests using Faraday.".freeze

  s.installed_by_version = "3.0.3.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multipart-post>.freeze, ["~> 2.0"])
    else
      s.add_dependency(%q<multipart-post>.freeze, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<multipart-post>.freeze, ["~> 2.0"])
  end
end
