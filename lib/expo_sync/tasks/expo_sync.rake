require 'rake'

namespace :expo_sync do
  desc "Start data sync with server"
  task :process => :environment do
    ExpoSync::Remote::GetContactAccountData.process!
    puts 'Done!'
  end
end