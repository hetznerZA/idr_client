require 'spec_helper'
require 'idr_client'

describe SoarSc::IdrClient do

  before(:each) do
    @valid_url = 'http://my-validish-url'
    @secure_valid_url = 'https://my-validish-url'
    @idr_client = SoarSc::IdrClient.new(@valid_url)
    @secure_idr_client = SoarSc::IdrClient.new(@secure_valid_url)
  end

  context 'when initialized without a uri' do
    it 'should throw argument error' do
      expect { 
        SoarSc::IdrClient.new 
      }.to raise_error ArgumentError
    end
  end

  context 'when initialized with an invalid url' do
    it 'should raise invalid url error' do 
      expect {
        SoarSc::IdrClient.new('invalid url')
      }.to raise_error URI::InvalidURIError
    end
  end

  context 'when initialized with valid url' do 

    it 'should return instance of idr client' do 
      expect(@idr_client).to be_an_instance_of(SoarSc::IdrClient)
    end

    it 'url property should be instance of uri http' do
      expect(@idr_client.url).to be_an_instance_of(URI::HTTP)
    end

    it 'url propertu should be instance of uri https' do
      expect(@secure_idr_client.url).to be_an_instance_of(URI::HTTPS)
    end

  end

  context 'when calling build params' do
    context 'with identifier' do
      it 'should return valid url params' do
        params = @idr_client.build_params 'my-identifier'
        expect(params).to eq('?identifier=my-identifier')
      end
    end
    context 'with identifier and role' do 
      it 'should return valid url param' do
        params = @idr_client.build_params 'my-identifier', 'my-role'
        expect(params).to eq('?identifier=my-identifier&role=my-role')
      end
    end
  end

  context 'when asking idr for attributes of a role for a subject identifier' do
    it 'should return ' do
      response = double('', :body => '{"status":"success","data":{"attributes":{"hetznerPerson":{"name_and_surname":"Charles Mulder","email_address":"charles.mulder@hetzner.co.za"}},"notifications":["success"]}}')
      http_client = double("Net::HTTP", :start => response)
      allow(http_client).to receive(:get).and_return(response)

      idr_client = SoarSc::IdrClient.new(@valid_url, http_client)

      roles = idr_client.ask_idr('subject-identifier', 'hetznerPerson')
      expect(roles['data']['attributes']['hetznerPerson']['name_and_surname']).to eq('Charles Mulder')
      expect(roles['data']['attributes']['hetznerPerson']['email_address']).to eq('charles.mulder@hetzner.co.za')
    end
  end

  context 'when asking idr for roles of subject identifier' do
    it 'should return array of roles' do
      response = double('', :body => '{"status":"success","data":{"roles":["hetznerPerson","inetOrgPerson","posixAccount","top"],"notifications":["success"]}}')
      http_client = double("Net::HTTP", :start => response)
      allow(http_client).to receive(:get).and_return(response)

      idr_client = SoarSc::IdrClient.new(@valid_url, http_client)

      roles = idr_client.ask_idr('subject-identifier')
      expect(roles['data']['roles']).to be_an_instance_of(Array)
    end
  end

end
