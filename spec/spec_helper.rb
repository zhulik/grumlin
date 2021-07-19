# frozen_string_literal: true

ENV["ENV"] ||= "test"
ENV["GREMLIN_URL"] ||= "ws://localhost:8182/gremlin"

require "csv"

require "async/rspec"
require "factory_bot"
require "nokogiri"

require "simplecov"

SimpleCov.start do
  add_filter "spec"
end

require "grumlin"
require "grumlin/test/rspec"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| load(f) }

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context(Async::RSpec::Reactor, gremlin_server: true)
  config.include_context(Grumlin::Test::RSpec::GremlinContext, gremlin_server: true)
  config.include_context(Grumlin::Test::RSpec::DBCleanerContext, gremlin_server: true)

  config.include_context(Async::RSpec::Reactor, practical_gremlin: true)
  config.include_context(Grumlin::Test::RSpec::GremlinContext, practical_gremlin: true)

  re = Regexp.compile("#{%w[spec grumlin practical_gremlin].join('[\\\/]')}[\\\\/]")
  config.define_derived_metadata(file_path: re) do |metadata|
    metadata[:practical_gremlin] ||= true
  end

  config.register_ordering(:global) do |items|
    next items if items.empty?

    groups = items.group_by { |item| item.metadata[:practical_gremlin] }
    (groups[true] || []) + (groups[nil] || []).shuffle
  end
end
