require 'net/https'
require 'uri'
require 'expo_sync/helpers/path_builder'

module ExpoSync
  SERVICE_URL = 'https://:domain/egvs/Forum/ForumService.svc/json/:method/:token/:project/:delta'.freeze

  class Base
    include ExpoSync::Helpers::PathBuilder
    cattr_accessor :service_domain

    attr_reader :remote_method
    attr_reader :response
    attr_reader :data

    def initialize(method)
      @remote_method = method
      initialize_connection
    end

    def fetch
      @response = @http.request Net::HTTP::Get.new(uri.request_uri)
    end

    def parse
      # ["AccountList", "CategoryAccountList", "CategoryList", "ContactList", "DeletedAccountIDs", "DeletedCategoryAccountIDs", "DeletedCategoryIDs", "DeletedContactIDs"]
      @data ||= JSON.parse(@response.body, object_class: RemoteData, symbolize_names: true)[:"#{remote_method}Result"]
      @data.normalize!
    end

    private
    def initialize_connection
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE # TODO: Check real ssl cert in prod
    end

    def uri
      # Test connect to Forum API
      @uri ||= URI.parse path_map(SERVICE_URL,
              :domain => ExpoSync::Base.service_domain,
              :method => remote_method,
              :token => "AAII2012Forum",
              :project => 1, # TODO: multiple projects
              :delta => 1) # TODO: implement delta
    end
  end
end