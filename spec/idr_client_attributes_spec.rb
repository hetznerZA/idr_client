require 'spec_helper'
require 'idr_client'

describe SoarSc::IdrClient do

  let(:attributes_uri) { 'http://incubator.dev.auto-h.net:8080/idr_staff/get-attributes' }
  let(:roles_uri) { 'http://incubator.dev.auto-h.net:8080/idr_staff/get-roles' }
  let(:subject_identifier) { 'charles.mulder@hetzner.co.za' }
  let(:role) { 'hetznerPerson' }

  describe '#attributes_uri' do

    let(:idr_client) { SoarSc::IdrClient.new }

    context 'valid attributes uri' do
      it 'should set attributes_uri instance attribute to a parsed uri' do
        idr_client.attributes_uri = attributes_uri
        expect(idr_client.attributes_uri).to be_an_instance_of(URI::HTTP)
      end
    end

    context 'invalid attributes uri' do
      it 'should raise invalid uri error' do
        expect {
          idr_client.attributes_uri = 'my invalid uri'
        }.to raise_error URI::InvalidURIError
      end
    end

  end

  describe '#get_attributes' do

    let(:idr_client) {
      roles_response = double('', :body => '{"status":"success","data":{"roles":["hetznerPerson","inetOrgPerson","posixAccount","top"],"notifications":["success"]}}')
      attributes_response = double('', :body => '{"status":"success","data":{"attributes":{"hetznerPerson":{"name_and_surname":"Charles Mulder","email_address":"charles.mulder@hetzner.co.za"}},"notifications":["success"]}}')
      http_client = double("Net::HTTP")
      allow(http_client).to receive(:start).and_return(roles_response, attributes_response)
      idr_client = SoarSc::IdrClient.new(http_client)
    }

    context 'without setting attributes uri' do
      it 'should raise missing required attribute error' do
        expect {
          idr_client.get_attributes(subject_identifier, role)
        }.to raise_error SoarSc::IdrClient::MissingRequiredAttributeError
      end
    end

    context 'valid attributes uri' do
      it 'should return array of attributes' do
        idr_client.attributes_uri = attributes_uri
        idr_client.roles_uri = roles_uri
        attributes = idr_client.get_attributes(subject_identifier, role)
        expect(attributes).to be_an_instance_of(Hash)
        expect(attributes['name_and_surname']).to eq('Charles Mulder')
        expect(attributes['email_address']).to eq('charles.mulder@hetzner.co.za')
      end
    end

    context 'without a subject identifier' do
    end

    context 'without a role' do
    end

    context 'network error' do
      it 'should throw a communication error' do
        idr_client = SoarSc::IdrClient.new
        idr_client.roles_uri = roles_uri
        idr_client.attributes_uri = 'http://localhost'
        expect {
          attributes = idr_client.get_attributes(subject_identifier, role)
        }.to raise_error SoarSc::IdrClient::CommunicationError
      end
    end

    context 'does not return json' do
      it 'should throw a unsupported response error' do
        idr_client.roles_uri = roles_uri
        idr_client.attributes_uri = attributes_uri
        expect {
          attributes = idr_client.get_attributes(subject_identifier, role)
        }.to raise_error SoarSc::IdrClient::UnsupportedResponseError
      end
    end

  end

end
