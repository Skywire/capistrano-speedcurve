require 'uri'
require "json"
require "net/http"

namespace :speedcurve do
  desc "Cache warm tested URL's after successful deployment"
  task :cachewarm do
    on release_roles :all do
      begin
        if fetch(:speedcurve_api_key)
            uri = URI("https://api.speedcurve.com/v1/urls")
            request = Net::HTTP::Get.new(uri)
            request.basic_auth "#{fetch(:speedcurve_api_key)}", "x"

            result = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
              http.request(request)
            }

            data = JSON.parse(result.body)

            data['sites'].each do |child|
              child['urls'].each do |child2|
                  result = Net::HTTP.get_response(URI(child2['url']))
                  puts child2['url']
                  puts result.code
              end
            end
          end
        rescue
          print("Cache Warm failed")
        end
    end
  end
  desc "Checks the currently checked out remote git branch matches the branch being deployed"
  task :notify do
    on release_roles :all do
      begin
        if fetch(:speedcurve_api_key)
          data_note = URI.escape("Deploying #{fetch(:current_revision)}")
          logs = (`git log #{fetch(:previous_revision)}..#{fetch(:current_revision)}`).scan(/\n\s\s\s(.+)\n/).
              flatten.
              map { |l| l.strip }.
              reject { |l| l.match(/^Merge pull request/) }
          execute "curl \"https://api.speedcurve.com/v1/deploys\" -u #{fetch(:speedcurve_api_key)}:x --request POST --data site_id=#{fetch(:speedcurve_site_id)} --data note=#{data_note} --data detail=#{logs}"
        end
      rescue
        print("Speedcurve notify failed")
      end
    end
  end
end

after "deploy:finished", "speedcurve:cachewarm"
after "speedcurve:cachewarm", "speedcurve:notify"
