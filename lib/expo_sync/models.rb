require 'active_support/concern'

module ExpoSync
  require 'mongoid'

  class DataModel
    include Mongoid::Document
    field :ProjectID
    default_scope -> { where(ProjectID: ExpoSync.project_id.to_i) }

    index "ProjectID" => 1

    def self.delete_all # Fix Mongoid bug
      super ProjectID: ExpoSync.project_id.to_i
    end
  end

  module CachedModel
    extend ActiveSupport::Concern

    included do
      after_destroy :remove_from_cache
      after_save :update_cache
    end

    private
    def update_cache
      langs = ExpoSync::ProjectCultureList.all.collect(&:Name)
      langs.each do |lang|
        I18n.with_locale(lang) do
          $redis.hset("#{self.class.cached_key}:#{lang}", self.id, self.to_json)
        end
      end
    end

    def remove_from_cache

      self.class.cached_keys.each do |key|
        $redis.hdel(key, id)
      end
    end

    def from_cache
      JSON.parse $redis.hget("#{self.class.cached_key}:#{I18n.locale}", id)
    end

    module ClassMethods
      def cached_key
        "#{Project.current.ProjectCode}:#{name.demodulize.underscore}"
      end

      def cached_keys
        $redis.keys("#{cached_key}:*")
      end

      def delete_all
        super
        $redis.del(*cached_keys)
      end

      def from_cache
        data = $redis.hgetall("#{cached_key}:#{I18n.locale}").values

        return if data.empty?

        JSON.parse "[#{data.join(', ')}]"
      end

      def rebuild_cache
        all.map(&:save)
      end
    end
  end
end

## Load all models
Dir[File.expand_path('../models/**/*.rb', __FILE__)].each do |model|
  require model
end
