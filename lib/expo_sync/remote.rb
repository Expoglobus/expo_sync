require 'expo_sync/base'
require 'expo_sync/remote_data'
require 'expo_sync/data_model'

module ExpoSync
  module Remote
    class GetContactAccountData < Base
      include ExpoSync::DataStorage

      cattr_accessor :deleted_fields


      self.data_array_fields  = [:AccessGroupList, :AccountList, :CategoryAccountList, :CategoryList, :ContactList, :ParticipationCategoryList, :ParticipiationAccessGroupList, :ProjectCultureList]
      self.data_object_fields = [:Project]
      self.deleted_fields     = [:DeletedAccountIDs, :DeletedCategoryAccountIDs, :DeletedCategoryIDs, :DeletedContactIDs]

      RemoteData.date_keys = [:UpdatedDateTime, :CreatedDateTime]

      def initialize
        super('GetContactAccountData')
      end

    end

    class GetRoomEventData < Base
      include ExpoSync::DataStorage

      self.data_array_fields  = [:BlockList, :EventList, :SectionGroupList, :SectionList]

      RemoteData.date_keys = [:UpdatedDateTime, :CreatedDateTime, :EventDate, :StartTime, :EndTime]

      def initialize
        super('GetRoomEventData', 'roomEventLastModified')
      end

    end
  end
end