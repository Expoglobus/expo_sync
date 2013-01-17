require 'faraday'
require 'active_support/all'
require 'expo_sync/helpers/path_builder'
require 'expo_sync/helpers/class_builder'

require 'expo_sync/data_utils'

module ExpoSync
  SERVICE_URL = 'https://:domain/egvs/Forum/ForumService.svc/json/:method'.freeze

  CULTURE_MAP = {1 => :en, 2 => :de, 3 => :ru}.freeze

  # Class var with default value
  mattr_accessor(:service_domain)
  mattr_accessor(:security_token)
  mattr_accessor(:project_id)

  class Base

    HEADERS = {'User-Agent' => "Expo Sync", 'Content-Type' => 'application/json'}.freeze

    include ExpoSync::Helpers::PathBuilder
    extend ExpoSync::Helpers::ClassBuilder

    attr_reader :method
    attr_reader :response
    attr_reader :data
    attr_reader :last_update_param

    class_attribute(:date_fields)
    self.date_fields = []

    def initialize(method, options = {})
      options.symbolize_keys!
      @delta = options.delete(:delta)
      @delta = {:key => @delta} if @delta.is_a? String
      @method = method
    end

    def fetch
      body = {}
      body[:securityToken] = ExpoSync.security_token
      body[:projectID] = ExpoSync.project_id
      if @delta
        body[@delta[:key]] = @delta[:value] || 1
      end

      @response = http.post do |request|
        puts body.inspect
        request.body = body.to_json
      end

    end

    def parse
      # ["AccountList", "CategoryAccountList", "CategoryList", "ContactList", "DeletedAccountIDs", "DeletedCategoryAccountIDs", "DeletedCategoryIDs", "DeletedContactIDs"]
      @data = JSON.parse(@response.body, object_class: RemoteData, symbolize_names: true)[:"#{@method}Result"]
      raise "Sync fail. Respose body: nil" unless @data
      @data.normalize!(date_fields)
      true
    end

    def http
      @http ||= Faraday.new path do |faraday|
        faraday.headers = HEADERS
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.ssl[:verify] = false # Disable SSL Verify. TODO: dont use in prod
        faraday.options[:timeout] = 360
      end
    end

    # Path to API
    def path
      path_map(SERVICE_URL, :domain => ExpoSync.service_domain, :method => @method)
    end

      def self.process!(force = false)
        instance = force ? self.new(:force => true) : self.new
        instance.fetch
        instance.parse
        instance
      end
  end
end