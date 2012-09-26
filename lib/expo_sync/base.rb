require 'faraday'
require 'active_support/all'
require 'expo_sync/helpers/path_builder'
require 'expo_sync/helpers/class_builder'

module ExpoSync
  SERVICE_URL = 'https://:domain/egvs/Forum/ForumService.svc/json/:method'.freeze

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

    def initialize(method, last_update_param = 'sinceDateTime')
      @method = method
      @last_update_param = last_update_param
    end

    def fetch
      @response = http.post do |request|
        params = {:securityToken => ExpoSync.security_token, :projectID => ExpoSync.project_id, :"#{last_update_param}" => 1}
        puts params.inspect
        request.body = {:securityToken => ExpoSync.security_token, :projectID => ExpoSync.project_id, :"#{last_update_param}" => 1}.to_json
      end

    end

    def parse
      # ["AccountList", "CategoryAccountList", "CategoryList", "ContactList", "DeletedAccountIDs", "DeletedCategoryAccountIDs", "DeletedCategoryIDs", "DeletedContactIDs"]
      @data ||= JSON.parse(@response.body, object_class: RemoteData, symbolize_names: true)[:"#{@method}Result"]
      @data.normalize!
    end

    def http
      @http ||= Faraday.new path do |faraday|
        faraday.headers = HEADERS
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.ssl[:verify] = false # Disable SSL Verify. TODO: dont use in prod
      end
    end

    # Path to API
    def path
      path_map(SERVICE_URL, :domain => ExpoSync.service_domain, :method => @method)
    end

      def self.process!
        instance = self.new
        instance.fetch
        instance.parse
        instance
      end
  end
end