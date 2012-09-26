require 'rake'

namespace :expo_sync do
  desc "Start data sync with server"
  task :process => :environment do
    puts "#### Sync ContactAccountData... "
    ExpoSync::Remote::GetContactAccountData.process!
    puts 'Done!'

    puts "#### Sync GetRoomEventData... "
    ExpoSync::Remote::GetRoomEventData.process!
  end
end