require 'uri'

namespace :speedcurve do
  desc "Checks the currently checked out remote git branch matches the branch being deployed"
  task :notify do
    on release_roles :all do
      if fetch(:speedcurve_api_key)
        data_note = URI.escape("Deploying #{fetch(:current_revision)}")
        logs = (`git log #{fetch(:previous_revision)}..#{fetch(:current_revision)}`).scan(/\n\s\s\s(.+)\n/).
            flatten.
            map { |l| l.strip }.
            reject { |l| l.match(/^Merge pull request/) }
        execute "curl \"https://api.speedcurve.com/v1/deploys\" -u #{fetch(:speedcurve_api_key)} --request POST --data site_id=#{fetch(:speedcurve_site_id)} --data note=#{data_note} --data detail=#{logs}"
      end
    end
  end
end

after "deploy:finished", "speedcurve:notify"
