require 'spec_helper'
require 'sidekiq/testing'
require 'sidekiq/testing/inline'

describe 'PlannerWorker' do
  before :all do
    # `mongorestore -d busify_test #{RAILS.root}/spec/fixtures/bristol`
    @worker = PlannerWorker.new
  end

  describe 'PlannerWorker.flesh_out_match' do
    it 'should flesh out stop details' do
      match = [
        {
          :route => 'cl-1-i',
          :stops => ['0100BRP90009', '0100BRP90086']
        },
        {
          :route => 'cl-70-o',
          :stops => ["0100BRA10451", "0100BRA10452", "0100BRA10453"]
        }
      ]
      fleshed = @worker.flesh_out_match match
      fleshed[0][:route].should eq '1'
      fleshed[0][:stops].length.should eq 2
      fleshed[0][:stops][1][:lat].should eq 51.46921
      fleshed[1][:route].should eq '70'
      fleshed[1][:stops].length.should eq 3
      fleshed[1][:stops].last[:name].should eq 'Whitmore Avenue'
    end
  end

  describe 'Planner.perform' do
    it 'should plan a journey between 2 points' do
      params = {}
      params['from'] = '51.47059080879994,-2.6150304933929647'
      params['to'] = '51.468031084263025,-2.5920171400451864'
      @worker.perform(params)
    end
  end  
end