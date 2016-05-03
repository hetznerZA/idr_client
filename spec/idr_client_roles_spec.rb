require 'spec_helper'
require 'idr_client'

describe SoarSc::IdrClient do

  let(:roles_uri) { 'http://incubator.dev.auto-h.net:8080/idr_staff/get-roles' }
  let(:subject_identifier) { 'charles.mulder@hetzner.co.za' }

  describe '#roles_uri' do

    let(:idr_client) { SoarSc::IdrClient.new }

    context 'valid uri' do
      it 'should set roles_uri instance attribute to a parsed uri' do
        idr_client.roles_uri = roles_uri
        expect(idr_client.roles_uri).to be_an_instance_of(URI::HTTP)
      end
    end

    context 'invalid uri' do
      it 'should raise invalid uri error' do
        expect {
          idr_client.roles_uri = 'my invalid uri'
        }.to raise_error URI::InvalidURIError
      end
    end
  end

  describe '#get_roles' do

    let(:idr_client) {
      roles_response = double('', :body => '{"status":"success","data":{"roles":["hetznerPerson","inetOrgPerson","posixAccount","top"],"notifications":["success"]}}')
      http_client = double("Net::HTTP")
      allow(http_client).to receive(:start).and_return(roles_response)
      idr_client = SoarSc::IdrClient.new(http_client)
    }

    context 'without setting roles uri' do
      it 'should raise missing required attribute error' do
        expect {
          idr_client.get_roles(subject_identifier)
        }.to raise_error SoarSc::IdrClient::MissingRequiredAttributeError
      end
    end

    context 'valid roles uri' do
      it 'should return array of roles' do
        idr_client.roles_uri = roles_uri
        roles = idr_client.get_roles(subject_identifier)
        expect(roles).to be_an_instance_of(Array)
      end
    end

    context 'network error' do
      it 'should throw a communication error' do
        idr_client = SoarSc::IdrClient.new
        idr_client.roles_uri = 'http://localhost'
        expect {
          roles = idr_client.get_roles(subject_identifier)
        }.to raise_error SoarSc::IdrClient::CommunicationError
      end
    end

    context 'does not return json' do
      it 'should throw a unsupported response error' do
        idr_client = SoarSc::IdrClient.new
        idr_client.roles_uri = roles_uri
        expect {
          roles = idr_client.get_roles(subject_identifier)
        }.to raise_error SoarSc::IdrClient::UnsupportedResponseError
      end
    end

  end

end
