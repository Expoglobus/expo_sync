module ExpoSync
  class RemoteData < Hash

    def date_fields
      @date_fields || []
    end

    def normalize!(fields = [])
      @date_fields = fields
      normalize_date!
      each do |_k, v|
        v.normalize!(date_fields) if v.kind_of?(RemoteData)
        v.map { |h| h.normalize!(date_fields) } if v.kind_of?(Array)
      end
    end

    def normalize_date!
      date_fields.each do |key|
        include?(key) ? self[key] = parse_date(self[key]) : next
      end
    end

    private
    def parse_date(str)
      if str =~ /\/Date\((\d+)((\+|\-)\d{2})\d{2}\)\// # Parse fuckin Jora "/Date(1345033161020+0300)/"
        Time.at($1.to_f / 1_000.0).getlocal("#{$2}:00")
      end
    end
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

      def process!(force = false)
        instance = super(force)
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