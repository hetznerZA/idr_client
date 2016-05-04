require 'uri'
require 'json'
require 'net/http'
require 'soar_idm/soar_idm'

module SoarSc

  class IdrClient < SoarIdm::IdmApi

    class MissingRequiredAttributeError < StandardError; end
    class CommunicationError < StandardError; end
    class UnsupportedResponseError < StandardError; end

    attr_accessor :roles_uri
    attr_accessor :attributes_uri

    def initialize(http=Net::HTTP)
      @http = http
    end

    def get_roles(subject_identifier)
      begin
        super(subject_identifier)
      rescue MissingRequiredAttributeError => error
        raise error
      rescue JSON::ParserError => error
        raise UnsupportedResponseError, error.message
      rescue StandardError => error
        raise CommunicationError, error.message
      end
    end

    def get_attributes(subject_identifier, role = nil)
      begin
        super(subject_identifier, role)
      rescue MissingRequiredAttributeError => error
        raise error
      rescue JSON::ParserError => error
        raise UnsupportedResponseError, error.message
      rescue StandardError => error
        raise CommunicationError, error.message
      end
    end

    def attributes_uri=(attributes_uri)
      raise URI::InvalidURIError if not valid_url?(attributes_uri)
      @attributes_uri = URI.parse(attributes_uri)
    end

    def roles_uri=(roles_uri)
      raise URI::InvalidURIError if not valid_url?(roles_uri)
      @roles_uri = URI.parse(roles_uri)
    end

    private 

    def calculate_identities(entity_identifier)
      [entity_identifier]
    end

    def calculate_all_attributes(identity)
      response = ask_idr(identity, nil, @attributes_uri)
      response['data']['attributes']
    end

    def calculate_roles(identity)
      raise MissingRequiredAttributeError, 'Missing required roles_uri' if @roles_uri.nil?
      response = ask_idr(identity, nil, @roles_uri)
      response['data']['roles']
    end

    def calculate_attributes(identity, role)
      raise MissingRequiredAttributeError, 'Missing required @attributes_uri attribute' if @attributes_uri.nil?
      response = ask_idr(identity, role, @attributes_uri)
      response['data']['attributes'][role]
    end 

    def ask_idr(identifier, role = nil, url)
      response = @http.start(url.host, url.port) do |http|
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
