require 'rake'

namespace :expo_sync do
  desc "Start data sync with server by project id"

  task "process:id", [:id] => :environment do |t, args|
    ExpoSync.project_id = args.id
    process
  end

  desc "Start data sync with server by default project id"
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
    force = !!ENV['FORCE']
    puts "#### Sync ContactAccountData... "
    ExpoSync::Remote::GetContactAccountData.process!(force)
    puts
    puts "#### Sync GetProjectData... "
    ExpoSync::Remote::GetProjectData.process!
    puts
    puts "#### Sync GetRoomEventData... "
    ExpoSync::Remote::GetRoomEventData.process!
    puts
    puts "Done!\n"
  end
end