module ExpoSync
  class Railtie < Rails::Railtie

    rake_tasks do
      load 'expo_sync/tasks/expo_sync.rake'
    end
  end
end