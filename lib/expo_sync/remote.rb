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


      self.data_array_fields  = [:AccessGroupList, :CategoryAccountList, :ParticipationCategoryList, :ParticipiationAccessGroupList, :ProjectCultureList]
      self.deleted_fields     = [:DeletedAccountIDs, :DeletedCategoryAccountIDs, :DeletedCategoryIDs, :DeletedContactIDs]

      RemoteData.date_keys = [:UpdatedDateTime, :CreatedDateTime]

      def initialize
        super('GetContactAccountData')
      end

      def store
        ExpoSync::AccountList.store_with_locale(data[:AccountList])
        ExpoSync::ContactList.store_with_locale(data[:ContactList])
        ExpoSync::CategoryList.store_with_locale(data[:CategoryList])
        ExpoSync::Project.store_with_locale(data[:Project])
        super
        true
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