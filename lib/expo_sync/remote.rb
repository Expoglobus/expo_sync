require 'expo_sync/base'
require 'expo_sync/remote_data'
require 'expo_sync/data_model'

require 'expo_sync/models/account_list'
require 'expo_sync/models/contact_list'
require 'expo_sync/models/category_list'
require 'expo_sync/models/category_account_list'
require 'expo_sync/models/project'

require 'expo_sync/models/event_list'
require 'expo_sync/models/block_list'

module ExpoSync
  module Remote
    class GetContactAccountData < Base
      include ExpoSync::DataStorage

      cattr_accessor :deleted_fields


      self.data_array_fields  = []
      self.deleted_fields     = [:DeletedAccountIDs, :DeletedCategoryAccountIDs, :DeletedCategoryIDs, :DeletedContactIDs]

      self.date_fields = [:UpdatedDateTime, :CreatedDateTime]

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
        ExpoSync::AccountList.store_with_locale(data[:AccountList], @delta[:value])
        ExpoSync::ContactList.store_with_locale(data[:ContactList], @delta[:value])
        ExpoSync::CategoryList.store_with_locale(data[:CategoryList], @delta[:value])
        ExpoSync::CategoryAccountList.store(data[:CategoryAccountList], @delta[:value])

        $redis.set(@redis_delta_key, data[:DeltaLastDateTime])
        true
      end

    end

    class GetRoomEventData < Base
      include ExpoSync::DataStorage

      self.data_array_fields  = [:SectionGroupList, :SectionList]

      self.date_fields = [:UpdatedDateTime, :CreatedDateTime, :EventDate, :StartTime, :EndTime, :AvailableFrom, :AvailableTo]

      def initialize
        super('GetRoomEventData', :delta => 'roomEventLastModified')
      end

      def store
        ExpoSync::EventList.store_with_locale(data[:EventList])
        ExpoSync::BlockList.store_with_locale(data[:BlockList])

        super
        true
      end

    end

    class GetProjectData < Base
      include ExpoSync::DataStorage
      self.data_array_fields = [:AccessGroupList, :ParticipationCategoryList, :ParticipiationAccessGroupList, :ProjectCultureList]

      self.date_fields = [:UpdatedDateTime, :CreatedDateTime, :EndDate, :StartDate]

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