#!/usr/bin/env ruby

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.command_name 'Kintama'
SimpleCov.start { add_filter '/tests/' }

require 'kintama'
require 'timeout'
require 'json'

require_relative '../lib/ezmq'
require_relative 'ezmq/context'
require_relative 'ezmq/socket'
require_relative 'ezmq/request'
require_relative 'ezmq/reply'
require_relative 'ezmq/publish'
require_relative 'ezmq/subscribe'
require_relative 'ezmq/push'
require_relative 'ezmq/pull'
require_relative 'ezmq/pair'
