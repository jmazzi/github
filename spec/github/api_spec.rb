require 'spec_helper'

describe Github::API do

  let(:api) { Github::API.new }
  let(:repos) { Github::Repos }

  it { described_class.included_modules.should include Github::Authorization }
  it { described_class.included_modules.should include Github::MimeType }
  it { described_class.included_modules.should include Github::Connection }
  it { described_class.included_modules.should include Github::Request }

  context 'actions' do
    it { described_class.new.should respond_to :api_methods_in }

    it 'dynamically adds actions inspection to classes inheriting from api' do
      repos.should respond_to :actions
      repos.new.should respond_to :actions
    end

    it 'ensures output contains api methods' do
      methods = [ 'method_a', 'method_b']
      repos.stub(:instance_methods).and_return methods
      output = capture(:stdout) { 
        api.api_methods_in(repos)
      }
      output.should =~ /.*method_a.*/
      output.should =~ /.*method_b.*/
    end
  end

  context '_normalize_params_keys' do
    before do
      @params = { 'a' => { :b => { 'c' => 1 }, 'd' => [ 'a', { :e => 2 }] } }
    end

    it "should stringify all the keys inside nested hash" do
      actual = api.send(:_normalize_params_keys, @params)
      expected = { 'a' => { 'b'=> { 'c' => 1 }, 'd' => [ 'a', { 'e'=> 2 }] } }
      actual.should be_eql expected
    end
  end

  context '_filter_params_key' do
    it "should remove non valid param keys" do
      valid = ['a', 'b', 'e']
      hash = {'a' => 1, 'b' => 3, 'c' => 2, 'd'=> 4, 'e' => 5 }
      actual = api.send(:_filter_params_keys, valid, hash)
      expected = {'a' => 1, 'b' => 3, 'e' => 5 }
      actual.should be_eql expected
    end
  end

end # Github::API
