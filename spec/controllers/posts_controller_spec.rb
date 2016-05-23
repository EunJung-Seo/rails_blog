
require 'spec_helper'
require 'rails_helper'

describe PostsController do
  describe '#index' do
    let!(:post) { create(:post) }
    it 'returns 200' do
      get :index
      expect(response.status).to eq 200
    end

    it 'returns json format' do
      get :index, format: :json
      expect(response.content_type).to eq('application/json')
    end

    it 'returns a post' do
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
    end
  end
end
