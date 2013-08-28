require 'optparse'
require 'net/https'
require 'uri'
require 'json'
require 'csv'

options = { :output => 'output.csv' }

option_parse = OptionParser.new do |opt|
  executable_name = File.basename($PROGRAM_NAME)
  opt.banner = "Grab issues from github repo.
  Usage: #{executable_name} [options] repo_url
  "

  opt.on("-o file_name", "--output file_name", 'Specify output file name. Default is output.csv.') do |file_name|
    options[:output] = file_name
  end

end

option_parse.parse!

if ARGV.empty?
  puts "error: you must supply a repo_url"
  puts
  puts option_parse.help
  exit
else
  options[:repo_url] = ARGV[0]
end

# start get issue
puts 'Start get issue from ' + options[:repo_url]
uri = URI.parse(options[:repo_url])
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)
#puts response.body
#puts response.status

unless response.code_type == Net::HTTPOK
  puts 'Get ' + options[:repo_url] + ' error: ' + response.code_type
  exit
end


issues = JSON.parse(response.body)
puts 'Get ' + issues.length.to_s + ' issues.'
puts 'Saving into ' + options[:output] + ' ...'
CSV.open(options[:output], 'w') do |csv|
  csv << ['id', 'summary', 'reporter', 'assignee', 'details']
  issues.each do |issue|
    csv << [issue['number'], issue['title'], issue['user']['login'], issue['assignee']['login'], issue['body']]
  end
end

puts 'Done.'
