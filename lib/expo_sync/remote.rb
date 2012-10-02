require 'expo_sync/base'
require 'expo_sync/remote_data'
require 'expo_sync/data_model'

require 'expo_sync/models/account_list'
require 'expo_sync/models/contact_list'
require 'expo_sync/models/category_list'
require 'expo_sync/models/project'

module ExpoSync
  module Remote
    class GetContactAccountData < Base
      include ExpoSync::DataStorage

      cattr_accessor :deleted_fields


      self.data_array_fields  = [:CategoryAccountList]
      self.deleted_fields     = [:DeletedAccountIDs, :DeletedCategoryAccountIDs, :DeletedCategoryIDs, :DeletedContactIDs]

      RemoteData.date_keys = [:UpdatedDateTime, :CreatedDateTime]

      #
      # ### Get data without delta
      # GetContactAccountData.new :force => true
      #
      def initialize(options = {})
        @redis_delta_key = "expo_sync:project:#{ExpoSync.project_id}:delta"
        @delta = $redis.get(@redis_delta_key) if !options[:force]
        super('GetContactAccountData', :delta => { :key => 'sinceDateTime', :value => @delta })
      end

      def store
        ExpoSync::AccountList.store_with_locale(data[:AccountList], @delta)
        ExpoSync::ContactList.store_with_locale(data[:ContactList], @delta)
        ExpoSync::CategoryList.store_with_locale(data[:CategoryList], @delta)

        $redis.set(@redis_delta_key, data[:DeltaLastDateTime])
        # ExpoSync::Project.store_with_locale(data[:Project])
        super
        true
      end

    end

    class GetRoomEventData < Base
      include ExpoSync::DataStorage

      self.data_array_fields  = [:BlockList, :EventList, :SectionGroupList, :SectionList]

      RemoteData.date_keys = [:UpdatedDateTime, :CreatedDateTime, :EventDate, :StartTime, :EndTime]

      def initialize
        super('GetRoomEventData', :delta => 'roomEventLastModified')
      end

    end

    class GetProjectData < Base
      include ExpoSync::DataStorage
      self.data_array_fields = [:AccessGroupList, :ParticipationCategoryList, :ParticipiationAccessGroupList, :ProjectCultureList]

      def initialize
        super('GetProjectData')
      end

      def store
        ExpoSync::Project.store_with_locale(data[:Project])
        super
        true
      end
    end

    class GetAllProjects < Base

      def initialize
        super('GetAllProjects')
      end
    end
  end
end