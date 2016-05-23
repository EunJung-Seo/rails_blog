require 'rails_helper'

describe PostsController do
  describe '#index' do
    let!(:post1) { create(:post) }
    it 'returns 200' do
      get :index
      expect(response.status).to eq 200
    end

    it 'returns json format' do
      get :index, format: :json
      expect(response.content_type).to eq('application/json')
    end

    let!(:post2) { create(:post) }
    it 'returns posts' do
      get :index, format: :json
      index_json = JSON.parse(response.body)
      expect(index_json.length).to eq 2
    end
  end

  describe '#show' do
    context 'with valid id' do
      let!(:post) { create(:post, title: 'show_title') }
      it 'returns 200' do
        get :show, id: post.id
        expect(response.status).to eq 200
      end

      it 'returns json format' do
        get :show, id: post.id, format: :json
        expect(response.content_type).to eq('application/json')
      end

      it 'retuns a post' do
        get :show, id: post.id, format: :json
        show_json = JSON.parse(response.body)
        expect(show_json['title']).to eq 'show_title'
      end
    end

    context 'with invalid id' do
      it 'redirect to index' do
        get :show, id: -10
        expect(response).to redirect_to(posts_url)
      end

      it 'returns no content' do
        get :show, id: -10, format: :json
        expect(JSON.parse(response.body)['status']).to eq 'cannot_found'
      end
    end
  end

  describe '#create' do
    new_post = {
      title: 'default title',
      name: 'test',
      content: 'new_content'
    }

    it 'returns 200' do
      post :create, new_post
      expect(response.status).to eq 200
    end

    # it 'returns json format' do
    #   post :create, new_post, format: :json
    #   expect(response.content_type).to eq('application/json')
    # end
  end

  describe '#update' do
    let!(:post) { create(:post) }
    it 'returns 302' do
      put :update, id: post.id
      expect(response.status).to eq 302
    end

    it 'returns json format' do
      put :update, id: post.id, format: :json
      expect(response.content_type).to eq('application/json')
    end
  end
end
