require 'rails_helper'

describe PostsController do
  describe '#index' do
    let!(:post1) { create(:post) }
    let!(:post2) { create(:post) }
    it 'returns 200' do
      get :index
      expect(response.status).to eq 200
    end

    it 'returns json format' do
      get :index, format: :json
      expect(response.content_type).to eq('application/json')
    end

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
        expect(JSON.parse(response.body)['title']).to eq 'show_title'
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
    context 'with valid attributes' do
      it 'create a new post' do
        expect { post :create, post: attributes_for(:post) }.to change(Post, :count).by(1)
      end

      it 'redirects to the new post' do
        post :create, post: attributes_for(:post)
        expect(response).to redirect_to(Post.last)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new post' do
        expect { post :create, post: attributes_for(:invalid_post) }.not_to change(Post, :count)
      end

      it 'renders new template' do
        post :create, post: attributes_for(:invalid_post)
        expect(response).to render_template('new')
      end
    end
  end

  describe '#update' do
    context 'with valid attributes' do
      let!(:post) { create(:post) }
      it 'changes post\'s attributes' do
        put :update, id: post.id, post: attributes_for(:post, title: 'new title')
        post.reload
        expect(post.title).to eq 'new title'
      end

      it 'redirects to the updated post' do
       put :update, id: post.id, post: attributes_for(:post, title: 'new title')
       post.reload
       expect(response).to redirect_to(post_path(post.id))
      end
    end

    context 'with invalid attributes' do
      let!(:post) { create(:post) }
      it 'does not change post\'s attributes' do
        put :update, id: post.id, post: attributes_for(:post, title: 'new title', name: nil)
        post.reload
        expect(post.title).to eq 'title'
      end

      it 'renders edit template' do
        put :update, id: post.id, post: attributes_for(:post, title: 'new title', name: nil)
        post.reload
        expect(response).to render_template('edit')
      end
    end
  end

  describe '#destroy' do
    let!(:post) { create(:post) }
    it 'redirects to index' do
      delete :destroy, id: post.id
      expect(response).to redirect_to(posts_url)
    end

    it 'removes the post' do
      delete :destroy, id: post.id, foramt: :json
      expect(Post.count).to eq 0
    end
  end
end
