require 'yaml'
require 'logger'

require 'active_support'
require 'active_support/core_ext'

require 'pry'
require 'slop'

require 'mailgun'
require 'rollbar'

require 'sucker_punch'

if !Dir.exist?("log")
  Dir.mkdir("log")
end

if !File.exist?("./log/data.yml")
  File.new("./log/data.yml", "w+")
end
