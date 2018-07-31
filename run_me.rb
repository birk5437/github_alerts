# ruby 2.2.5
require 'github_api'
require 'yaml'
require 'active_support/all'
require 'date'

require "./alerts_manager.rb"
require "./pull_request.rb"
require "./logger.rb"

config = YAML.load_file('./secrets.yml').symbolize_keys


manager = AlertsManager.new({
  github_username:      config[:github_username],
  github_api_key:       config[:github_api_key],
  repo_owner:           config[:repo_owner],
  repo_name:            config[:repo_name]
})

puts ARGV[0]
if manager.has_internet?
  prs = manager.pull_requests
  if ARGV[0].present?
    res = prs.select{ |r| r.files.detect{ |f| f.downcase.include?(ARGV[0].to_s.downcase) }.present? }
  else
    puts "Must provide an argument!"
    res = []
  end



  max_branch_name_size = res.map(&:branch_name).map(&:length).max
  res.each do |r|
    relevant_files = r.files.select{ |f| !f.end_with?(".yml") }
    Logger.log("#{r.created_at} | #{relevant_files.length.to_s.ljust(4, ' ')} | #{r.branch_name.ljust(max_branch_name_size, ' ')} | #{r.number} | #{r.author} | #{r.title}", false)
  end
else
  puts "No internet!"
end
