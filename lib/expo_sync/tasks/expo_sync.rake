require 'rake'

namespace :expo_sync do
  desc "Start data sync with server"
  task :process => :environment do
    process
  end

  desc "Start data sync All projects with server"
  task 'process:all' => :environment do
    # TODO: get projects by server
    (9..12).each do |id|
      ExpoSync.project_id = id
      process
    end
  end

  def process
    puts "#### Sync ContactAccountData... "
    ExpoSync::Remote::GetContactAccountData.process!
    puts
    puts
    puts "#### Sync GetRoomEventData... "
    ExpoSync::Remote::GetRoomEventData.process!
    puts "Done!\n"
  end
end