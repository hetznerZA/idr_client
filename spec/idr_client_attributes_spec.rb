require 'spec_helper'
require 'idr_client'

describe SoarSc::IdrClient do

  before(:each) do
    @attributes_uri = 'http://incubator.dev.auto-h.net:8080/idr_staff/get-attributes'
    @roles_uri = 'http://incubator.dev.auto-h.net:8080/idr_staff/get-roles'
    @subject_identifier = 'charles.mulder@hetzner.co.za'
    @role = 'hetznerPerson'
  end

  context 'when setting attributes uri' do

    before(:each) do
      @idr_client = SoarSc::IdrClient.new
    end

    context 'valid uri' do
      describe 'when setting attributes uri' do
        it 'should set attributes_uri instance attribute to a parsed uri' do
          @idr_client.attributes_uri = @attributes_uri
          expect(@idr_client.attributes_uri).to be_an_instance_of(URI::HTTP)
        end
      end
    end

    context 'invalid uri' do
      describe 'when setting attributes uri' do
        it 'should raise invalid uri error' do
          expect {
            @idr_client.attributes_uri = 'my invalid uri'
          }.to raise_error URI::InvalidURIError
        end
      end
    end
  end

  context 'when getting attributes of a role for a subject identifier' do

    before(:each) do
      roles_response = double('', :body => '{"status":"success","data":{"roles":["hetznerPerson","inetOrgPerson","posixAccount","top"],"notifications":["success"]}}')
      attributes_response = double('', :body => '{"status":"success","data":{"attributes":{"hetznerPerson":{"name_and_surname":"Charles Mulder","email_address":"charles.mulder@hetzner.co.za"}},"notifications":["success"]}}')
      http_client = double("Net::HTTP")
      allow(http_client).to receive(:start).and_return(roles_response, attributes_response)
      @idr_client = SoarSc::IdrClient.new(http_client)
    end

    context 'without setting attributes uri' do
      describe 'getting attributes' do
        it 'should raise missing required attribute error' do
          expect {
            @idr_client.get_attributes(@subject_identifier, @role)
          }.to raise_error SoarSc::IdrClient::MissingRequiredAttributeError
        end
      end
    end

    context 'without setting roles uri' do
      describe 'getting attributes' do
        it 'should raise missing required attribute error' do
          @idr_client.attributes_uri = @attributes_uri
          expect {
            @idr_client.get_attributes(@subject_identifier, @role)
          }.to raise_error SoarSc::IdrClient::MissingRequiredAttributeError
        end
      end
    end

    context 'after setting attributes uri' do
      describe 'getting attributes' do
        it 'should return array of attributes' do
          @idr_client.attributes_uri = @attributes_uri
          @idr_client.roles_uri = @roles_uri
          attributes = @idr_client.get_attributes(@subject_identifier, @role)
          expect(attributes).to be_an_instance_of(Hash)
          expect(attributes['name_and_surname']).to eq('Charles Mulder')
          expect(attributes['email_address']).to eq('charles.mulder@hetzner.co.za')
        end
      end
    end

  end

end
