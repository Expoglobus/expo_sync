require 'expo_sync/base'
require 'expo_sync/remote_data'
require 'expo_sync/data_model'

module ExpoSync
  module Remote
    class GetContactAccountData < Base
      cattr_accessor :data_array_fields
      cattr_accessor :data_object_fields
      cattr_accessor :deleted_fields


      self.data_array_fields  = [:AccessGroupList, :AccountList, :CategoryAccountList, :CategoryList, :ContactList, :ParticipationCategoryList, :ParticipiationAccessGroupList, :ProjectCultureList]
      self.data_object_fields = [:Project]
      self.deleted_fields     = [:DeletedAccountIDs, :DeletedCategoryAccountIDs, :DeletedCategoryIDs, :DeletedContactIDs]

      RemoteData.date_keys = [:UpdatedDateTime, :CreatedDateTime]

      def initialize
        super('GetContactAccountData')
      end

      def store
        data_array_fields.each do |field|
          store_object(field)
        end

        # This is one object
        # TODO: MAke a singletone
        data_object_fields do |field|
          klass = "ExpoSync::#{field}".constantize
          klass.destroy_all
          klass.create(data[field])
        end
      end

      def self.process!
        r = self.new
        r.fetch
        r.parse
        r.store
      end

      def self.build_models!
        (data_array_fields + data_object_fields).each do |field|
          create_class(field, ExpoSync::DataModel)
        end
      end

      private
      def store_object(field)
        klass = "ExpoSync::#{field}".constantize
        klass.destroy_all # Clear all data
        data[field].each do |object|
          klass.create(object)
        end
      end
    end
  end
end