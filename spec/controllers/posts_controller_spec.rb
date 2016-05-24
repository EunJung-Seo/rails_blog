require 'rails_helper'

describe PostsController do
  describe '#index' do
    context 'when respond format is JSON' do
      let!(:post_list) { create_list :post, 2 }
      subject { get :index, format: :json }
      it 'returns 200' do
        subject
        expect(response.status).to eq 200
      end

      it 'returns posts' do
        subject
        expect(JSON.parse(response.body).length).to eq 2
      end
    end

    context 'when respond format is html' do
      let!(:post_list) { create_list :post, 2 }
      subject { get :index }
      it 'returns 200' do
        subject
        expect(response.status).to eq 200
      end

      it 'returns posts' do
        subject
        expect(assigns(:posts)).to eq post_list
      end
    end
  end

  describe '#show' do
    describe 'JSON' do
      context 'with valid id' do
        let!(:post) { create(:post, title: 'show_title') }
        subject { get :show, id: post.id, format: :json }

        it 'returns 200' do
          subject
          expect(response.status).to eq 200
        end

        it 'returns the post' do
          subject
          expect(JSON.parse(response.body)['title']).to eq 'show_title'
        end
      end

      context 'with invalid id' do
        subject { get :show, id: -10, format: :json }
        it 'returns 404' do
          subject
          expect(response.status).to eq 404
        end

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Post not found'
        end
      end
    end

    describe 'html' do
      context 'with valid id' do
        let!(:post) { create(:post, title: 'show_title') }
        subject { get :show, id: post.id }

        it 'returns 200' do
          subject
          expect(response.status).to eq 200
        end

        it 'renders show template' do
          subject
          expect(response).to render_template('show')
        end

        it 'renders the post' do
          subject
          expect(assigns(:post)).to eq post
        end
      end

      context 'with invalid id' do
        subject { get :show, id: -10 }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end

        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end
    end
  end

  describe '#create' do
    describe 'JSON' do
      context 'with valid attributes' do
        subject { post :create, post: attributes_for(:post), format: :json }
        
        it 'returns 201' do
          subject
          expect(response.status).to  eq 201
        end

        it 'has a default title' do
          subject
          expect(JSON.parse(response.body)['title']).to eq 'title'
        end

        it 'has a default name' do
          subject
          expect(JSON.parse(response.body)['name']).to eq 'user1'
        end

        it 'has a default content' do
          subject
          expect(JSON.parse(response.body)['content']).to eq 'content'
        end
      end

      context 'with invalid name attribute' do
        subject { post :create, post: attributes_for(:invalid_post_name), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end

        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['name']).not_to be_empty
        end
      end

      context 'with invalid title attribute' do
        subject { post :create, post: attributes_for(:invalid_post_title), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end

        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['title']).not_to be_empty
        end
      end

      context 'when title is short than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end

        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['title']).not_to be_empty
        end
      end
    end

    describe 'html' do
      context 'with valid attributes' do
        subject { post :create, post: attributes_for(:post) }
        
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end

        it 'has a default title' do
          subject
          expect(assigns[:post]['title']).to eq 'title'
        end

        it 'has a default name' do
          subject
          expect(assigns[:post]['name']).to eq 'user1'
        end

        it 'has a default content' do
          subject
          expect(assigns[:post]['content']).to eq 'content'
        end
      end
    end

    context 'with invalid name attribute' do
      subject { post :create, post: attributes_for(:invalid_post_name) }
      it 'returns 200' do
        subject
        expect(response.status).to eq 200
      end

      it 'renders new template' do
        subject
        expect(response).to render_template('new')
      end
    end

    context 'with invalid title attribute' do
      subject { post :create, post: attributes_for(:invalid_post_title) }
      it 'returns 200' do
        subject
        expect(response.status).to eq 200
      end

      it 'renders new template' do
        subject
        expect(response).to render_template('new')
      end
    end

    context 'when title is short than 5 characters' do
      subject { post :create, post: attributes_for(:short_post_title) }
      it 'returns 200' do
        subject
        expect(response.status).to eq 200
      end

      it 'renders new template' do
        subject
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
      delete :destroy, id: post.id, format: :json
      expect(Post.count).to eq 0
    end
  end
end
