ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new(color: true)


module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    def is_logged_in?
      !session[:user_id].nil?
    end
  end

  
end
