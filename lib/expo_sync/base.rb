require 'faraday'
require 'active_support/all'
require 'expo_sync/helpers/path_builder'
require 'expo_sync/helpers/class_builder'

module ExpoSync
  SERVICE_URL = 'https://:domain/egvs/Forum/ForumService.svc/json/:method'.freeze

  class Base

    HEADERS = {'User-Agent' => "Expo Sync", 'Content-Type' => 'application/json'}.freeze

    include ExpoSync::Helpers::PathBuilder
    extend ExpoSync::Helpers::ClassBuilder

    # Class var with default value
    cattr_accessor(:service_domain) { 'alpha' }
    cattr_accessor(:security_token) { 'AAII2012Forum' }

    attr_reader :method
    attr_reader :response
    attr_reader :data

    def initialize(method)
      @method = method
    end

    def fetch
      @response = http.post do |request|
        request.body = {:securityToken => security_token, :projectID => 1, :sinceDateTime => 1}.to_json
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
      path_map(SERVICE_URL, :domain => service_domain, :method => @method)
    end
  end
end