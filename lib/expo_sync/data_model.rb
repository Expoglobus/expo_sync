require 'active_support/concern'

module ExpoSync
  require 'mongoid'

  class DataModel
    include Mongoid::Document
    default_scope -> { where(ProjectID: ExpoSync.project_id) }
  end

  module DataStorage
    extend ActiveSupport::Concern

    included do
      cattr_accessor(:data_array_fields) { [] }
      cattr_accessor(:data_object_fields) { [] }
    end

    module ClassMethods

      def build_models!
        (data_array_fields + data_object_fields).each do |field|
          create_class(field, ExpoSync::DataModel)
        end
      end

      def process!
        instance = super
        instance.store
      end
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

  private
    def store_object(field)
      klass = "ExpoSync::#{field}".constantize
      klass.destroy_all # Clear all data
      data[field].each do |object|
        klass.create(object)
      end if data[field].kind_of? Array
    end
  end
end
