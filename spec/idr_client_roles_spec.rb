require 'spec_helper'
require 'idr_client'

describe SoarSc::IdrClient do

  before(:each) do
    @roles_uri = 'http://incubator.dev.auto-h.net:8080/idr_staff/get-roles'
    @subject_identifier = 'charles.mulder@hetzner.co.za'
  end

  context 'when setting roles uri' do

    before(:each) do
      @idr_client = SoarSc::IdrClient.new
    end

    context 'valid uri' do
      describe 'when setting roles uri' do
        it 'should set roles_uri instance attribute to a parsed uri' do
          @idr_client.roles_uri = @roles_uri
          expect(@idr_client.roles_uri).to be_an_instance_of(URI::HTTP)
        end
      end
    end

    context 'invalid uri' do
      describe 'when setting roles uri' do
        it 'should raise invalid uri error' do
          expect {
            @idr_client.roles_uri = 'my invalid uri'
          }.to raise_error URI::InvalidURIError
        end
      end
    end
  end

  context 'when getting roles for a subject identifier' do

    before(:each) do
      roles_response = double('', :body => '{"status":"success","data":{"roles":["hetznerPerson","inetOrgPerson","posixAccount","top"],"notifications":["success"]}}')
      http_client = double("Net::HTTP")
      allow(http_client).to receive(:start).and_return(roles_response)
      @idr_client = SoarSc::IdrClient.new(http_client)
    end

    context 'without setting roles uri' do
      describe 'getting roles' do
        it 'should raise missing required attribute error' do
          expect {
            @idr_client.get_roles(@subject_identifier)
          }.to raise_error SoarSc::IdrClient::MissingRequiredAttributeError
        end
      end
    end

    context 'after setting roles uri' do
      describe 'getting roles' do
        it 'should return array of roles' do
          @idr_client.roles_uri = @roles_uri
          roles = @idr_client.get_roles(@subject_identifier)
          expect(roles).to be_an_instance_of(Array)
        end
      end
    end

  end

end
