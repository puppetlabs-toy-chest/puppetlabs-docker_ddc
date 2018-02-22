source 'https://rubygems.org'

group :test do
  gem 'gettext-setup'
  gem "json_pure", "<= 2.0.1" # 2.0.2 requires Ruby 2+
  gem 'metadata-json-lint'
  gem 'parallel_tests'
  if puppet_gem_version = ENV['PUPPET_GEM_VERSION']
    gem "puppet", puppet_gem_version
  elsif puppet_git_url = ENV['PUPPET_GIT_URL']
    gem "puppet", :git => puppet_git_url
  else
    gem "puppet"
  end 
  gem "puppet-lint", "2.3.3"
  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check'
  gem "puppet-lint-i18n"
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-unquoted_string-check', '0.3.0'
  gem 'puppet-lint-version_comparison-check'
  gem "puppet_pot_generator"
  gem 'puppetlabs_spec_helper'
  gem 'rake', ' 10.4.2'
  gem 'rspec'
  gem 'rspec-core', '>= 3.4' 
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'rspec-puppet-facts'
  gem "rspec-retry"
  gem 'rspec_junit_formatter', '~> 0.2.3'
  gem 'rubocop'
  gem 'rubocop-i18n'
  gem 'rubocop-rspec'
  gem 'semantic_puppet'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
end

group :development do
  gem 'guard-rake'
  gem "pry"
  gem 'puppet-blacksmith'
  gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppetlabs-strings.git'
  gem 'travis'
  gem 'travis-lint'
  gem "yard"
end

group :acceptance do
  gem "beaker", "~> 2.0"
  gem 'beaker-puppet_install_helper', :require => false
  gem 'beaker-rspec'
end
