require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                           SHARED EXAMPLES
  #
  # ===============================================================
  shared_examples 'invalid post parameter in json request' do |attribute|
    it 'returns 422' do
      subject
      expect(response.status).to eq 422
    end
    it 'returns error message' do
      subject
      expect(JSON.parse(response.body)[attribute]).not_to be_empty
    end
  end

  shared_examples 'valid post parameter' do |format, attribute, content|
    it "has a default #{attribute}" do
      subject
      if format == 'json'
        expect(JSON.parse(response.body)[attribute]).to eq content
      else
        expect(assigns[:post][attribute]).to eq content
      end
    end
  end

  # shared_examples 'valid post parameter in html request' do |attribute, content|
  #   it "has a default #{attribute}" do
  #     subject
      
  #   end
  # end

  shared_examples 'rendering template' do |action|
    it "reders #{action} template" do
      subject
      expect(response).to render_template(action)
    end
  end

  shared_examples 'update post parameter' do |attribute, content|
    it "changes post\'s #{attribute}" do
      put :update, id: post.id, post: { attribute => content }
      post.reload
      expect(post[attribute]).to eq content
    end
  end

  shared_examples 'update invalid post parameter in json request' do |attribute, content|
    it 'returns 422' do
      put :update, id: post.id, post: { attribute => content }, format: :json
      expect(response.status).to eq 422
    end
    it 'returns a error message' do
      put :update, id: post.id, post: { attribute => content }, format: :json
      expect(JSON.parse(response.body)[attribute]).not_to be_empty
    end
  end

  shared_examples 'return response status' do |code|
    it "returns #{code}" do
      subject
      expect(response.status).to eq code
    end
  end



  # ===============================================================
  #
  #                              TESTS
  #
  # ===============================================================
  describe '#index' do
    context 'when respond format is JSON' do
      let!(:post_list) { create_list :post, 2 }
      subject { get :index, format: :json }

      include_examples 'return response status', 200

      it 'returns posts' do
        subject
        expect(response.body).to eq post_list.to_json
      end
    end

    context 'when respond format is html' do
      let!(:post_list) { create_list :post, 2 }
      subject { get :index }

      include_examples 'return response status', 200

      it 'returns posts' do
        subject
        expect(assigns(:posts)).to eq post_list
      end
    end
  end

  describe '#show' do
    describe 'JSON' do
      context 'with valid id' do
        let(:post) { create(:post, title: 'show_title') }
        subject { get :show, id: post.id, format: :json }

        include_examples 'return response status', 200

        it 'returns the post' do
          subject
          expect(JSON.parse(response.body)['title']).to eq 'show_title'
        end
      end

      context 'with invalid id' do
        subject { get :show, id: -10, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Post not found'
        end
      end
    end

    describe 'html' do
      context 'with valid id' do
        let(:post) { create(:post, title: 'show_title') }
        subject { get :show, id: post.id }

        include_examples 'return response status', 200

        it 'assigns post to @post' do
          subject
          expect(assigns(:post)).to eq post
        end

        include_examples 'rendering template', 'show'
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
        
        include_examples 'return response status', 201

        include_examples 'valid post parameter', 'json', 'title', 'title'
        include_examples 'valid post parameter', 'json', 'name', 'user1'
        include_examples 'valid post parameter', 'json', 'content', 'content'
      end

      context 'with invalid title attribute' do
        subject { post :create, post: attributes_for(:invalid_post_title), format: :json }
        include_examples 'invalid post parameter in json request', 'title'
      end

      context 'with invalid name attribute' do
        subject { post :create, post: attributes_for(:invalid_post_name), format: :json }
        include_examples 'invalid post parameter in json request', 'name'
      end

      context 'when title is short than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title), format: :json }
        include_examples 'invalid post parameter in json request', 'title'
      end
      
    end

    describe 'html' do
      context 'with valid attributes' do
        subject { post :create, post: attributes_for(:post) }
        
        include_examples 'return response status', 302

        include_examples 'valid post parameter', 'html', 'title', 'title'
        include_examples 'valid post parameter', 'html', 'name', 'user1'
        include_examples 'valid post parameter', 'html', 'content', 'content'
      end
      context 'with invalid title attribute' do
        subject { post :create, post: attributes_for(:invalid_post_name) }
        include_examples 'rendering template', 'new'
      end

      context 'with invalid name attribute' do
        subject { post :create, post: attributes_for(:invalid_post_title) }
        include_examples 'rendering template', 'new'
      end

      context 'when title is short than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title) }
        include_examples 'rendering template', 'new'
      end
    end
  end

  describe '#update' do
    describe 'JSON' do
      let(:post) { create(:post) }
      context 'with valid name attribute' do
        subject do
          put :update,
          id: post.id,
          post: attributes_for(:post, name: 'new user'),
          format: :json
        end
        include_examples 'return response status', 204
        include_examples 'update post parameter', 'name', 'new user'
      end

      context 'with valid title attribute' do
        subject do
          post :create,
          id: post.id,
          post: attributes_for(:post, title: 'new title'),
          format: :json
        end
        include_examples 'return response status', 204
        include_examples 'update post parameter', 'title', 'new title'
      end

      context 'with valid content attribute' do
        subject do
          post :create,
          id: post.id,
          post: attributes_for(:post, content: 'new content'),
          format: :json
        end
        include_examples 'return response status', 204
        include_examples 'update post parameter', 'content', 'new content'
      end

      # case 2 : subject 없이
      context 'with invalid attribute' do
        include_examples 'update invalid post parameter in json request', 'name', nil
        include_examples 'update invalid post parameter in json request', 'title', nil
        include_examples 'update invalid post parameter in json request', 'title', 'a' 
      end

      context 'with invalid id' do
        subject do
          put :update,
          id: 0,
          post: attributes_for(:post),
          format: :json
        end
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Post not found'
        end
      end
    end

    describe 'html' do
      let(:post) { create(:post) }

      # context 'with valid attribute' do
      #   include_examples 'update post parameter', 'name', 'new user'
      #   include_examples 'update post parameter', 'title', 'new title'
      #   include_examples 'update post parameter', 'content', 'new content'
      # end

      context 'with valid name attribute' do
        subject { post :create, id: post.id, post: attributes_for(:post, name: 'new user') }
        include_examples 'return response status', 302
        include_examples 'update post parameter', 'name', 'new user'
      end

      context 'with valid title attribute' do
        subject { post :create, id: post.id, post: attributes_for(:post, title: 'new title') }
        include_examples 'return response status', 302
        include_examples 'update post parameter', 'title', 'new title'
      end

      context 'with valid content attribute' do
        subject { post :create, id: post.id, post: attributes_for(:post, content: 'new content') }
        include_examples 'return response status', 302
        include_examples 'update post parameter', 'content', 'new content'
      end

      context 'with invalid name attribute' do
        subject do
          put :update,
          id: post.id,
          post: attributes_for(:invalid_post_name)
        end
        include_examples 'rendering template', 'edit'
      end

      context 'with invalid title attribute' do
        subject do
          put :update,
          id: post.id,
          post: attributes_for(:invalid_post_title)
        end
        include_examples 'rendering template', 'edit'
      end

      context 'when title is short than 5 characters' do
        subject do
          put :update,
          id: post.id,
          post: attributes_for(:short_post_title)
        end
        include_examples 'rendering template', 'edit'
      end

      context 'with invalid id' do
        subject do
          put :update,
          id: 0,
          post: attributes_for(:post)
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end
    end
  end

  describe '#destroy' do
    describe 'JSON' do
      context 'with valid id' do
        let(:post) { create(:post) }
        subject { delete :destroy, id: post.id, format: :json }
        
        include_examples 'return response status', 204

        it 'removes the post' do
          subject
          expect(Post.find_by_id(post.id)).to eq nil
        end
      end

      context 'with invalid id' do
        subject { delete :destroy, id: 0, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Post not found'
        end
      end
    end

    describe 'html' do
      context 'with valid id' do
        let(:post) { create(:post) }
        subject { delete :destroy, id: post.id }

        include_examples 'return response status', 302

        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end

        it 'removes the post' do
          subject
          expect(Post.find_by_id(post.id)).to eq nil
        end
      end

      context 'with invalid id' do
        subject { delete :destroy, id: 0 }
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end
    end
  end
end
