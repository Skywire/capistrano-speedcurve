require 'uri'
require "json"
require "net/http"

namespace :speedcurve do
  desc "Cache warm tested URL's after successful deployment"
  task :cachewarm do
    on release_roles :all do
      if fetch(:speedcurve_api_key)
          uri = URI("https://api.speedcurve.com/v1/urls")
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(fetch(:speedcurve_api_key), "x")

          result = Net::HTTP.start(uri.hostname, uri.port) {|http|
            http.request(request)
          }

          #data = JSON.parse(result.body)

puts uri.host
puts uri.port
puts uri.request_uri
puts fetch(:speedcurve_api_key)
          puts result.code

          #data['data']['children'].each do |child|
          #    puts child['data']['body']
          #end
        end
    end
  end
  desc "Checks the currently checked out remote git branch matches the branch being deployed"
  task :notify do
    on release_roles :all do
      if fetch(:speedcurve_api_key)
            data_note = URI.escape("Deploying #{fetch(:current_revision)}")
            logs = (`git log #{fetch(:previous_revision)}..#{fetch(:current_revision)}`).scan(/\n\s\s\s(.+)\n/).
                flatten.
                map { |l| l.strip }.
                reject { |l| l.match(/^Merge pull request/) }
            execute "curl \"https://api.speedcurve.com/v1/deploys\" -u #{fetch(:speedcurve_api_key)}:x --request POST --data site_id=#{fetch(:speedcurve_site_id)} --data note=#{data_note} --data detail=#{logs}"
        end
      end
  end
end

after "deploy:finished", "speedcurve:cachewarm"
#after "speedcurve:cachewarm", "speedcurve:notify"
