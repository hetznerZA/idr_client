require 'uri'
require 'json'
require 'net/http'

module SoarSc
  class IdrClient

    attr_reader :url

    def initialize(uri, http=Net::HTTP)
      raise ArgumentError, 'Please initialize me with a uri' if uri.nil?
      raise URI::InvalidURIError if not valid_url?(uri)
      @url = URI.parse(uri)
      @http = http
    end

    def ask_idr(identifier, role = nil)
      response = @http.start(@url.host, @url.port) do |http|
        params = build_params(identifier, role)
        http.get(url.path + params)
      end
      JSON.parse(response.body)
    end

    def build_params(identifier, role = nil)
      params = "?identifier=#{identifier}"
      params += "&role=#{role}" if not role.nil?
      params
    end

    def valid_url?(uri)
      result = uri =~ /\A#{URI::regexp(['http', 'https'])}\z/
      not result.nil?
    end

  end
end
