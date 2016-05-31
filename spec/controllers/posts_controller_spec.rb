# -*- encoding : utf-8 -*-
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                           SHARED EXAMPLES
  #
  # ===============================================================
  # shared_examples 'invalid post parameter' do |format, attribute|
  #   it 'returns error message' do
  #     subject
  #     if format == 'json'
  #       expect(JSON.parse(response.body)[attribute]).not_to be_empty
  #     else

  #     end
  #   end
  # end

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

  # ===============================================================
  #
  #                              TESTS
  #
  # ===============================================================
  describe '#index' do
    let!(:post_list) { create_list :post, 2 }
    context 'when respond format is JSON' do
      subject { get :index, format: :json }

      it "returns 200" do
        subject
        expect(response.status).to eq 200
      end

      it 'returns posts' do
        subject
        expect(response.body).to eq post_list.to_json
      end
    end

    context 'when respond format is html' do
      subject { get :index }

      it "returns 200" do
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
    let(:post) { create :post }
    describe 'JSON' do
      context 'with valid id' do
        subject { get :show, id: post.id, format: :json }

        it "returns 200" do
          subject
          expect(response.status).to eq 200
        end

        it 'returns the post' do
          subject
          expect(JSON.parse(response.body)['title']).to eq 'New! 새글!'
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
        subject { get :show, id: post.id }

        it "returns 200" do
          subject
          expect(response.status).to eq 200
        end

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

        it "returns 200" do
          subject
          expect(response.status).to eq 201
        end

        include_examples 'valid post parameter', 'json', 'title', 'New! 새글!'
        include_examples 'valid post parameter', 'json', 'name', 'test_name'
        include_examples 'valid post parameter', 'json', 'content', '어제는 밥, 오늘은 면, 내일은 빵?'
      end

      context 'with invalid title attribute' do
        subject { post :create, post: attributes_for(:invalid_post_title), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'with invalid name attribute' do
        subject { post :create, post: attributes_for(:invalid_post_name), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'when title is short than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end
    end

    describe 'html' do
      context 'with valid attributes' do
        subject { post :create, post: attributes_for(:post) }

        it "returns 302" do
          subject
          expect(response.status).to eq 302
        end

        include_examples 'valid post parameter', 'html', 'title', 'New! 새글!'
        include_examples 'valid post parameter', 'html', 'name', 'test_name'
        include_examples 'valid post parameter', 'html', 'content', '어제는 밥, 오늘은 면, 내일은 빵?'
      end

      context 'with invalid name attribute' do
        subject { post :create, post: attributes_for(:invalid_post_name) }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'returns error message' do
          subject
          expect(flash.alert).to eq '유효하지 않은 포스트입니다.'
        end
      end

      context 'with invalid title attribute' do
        subject { post :create, post: attributes_for(:invalid_post_title) }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'returns error message' do
          subject
          expect(flash.alert).to eq '유효하지 않은 포스트입니다.'
        end
      end

      context 'when title is short than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title) }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'returns error message' do
          subject
          expect(flash.alert).to eq '유효하지 않은 포스트입니다.'
        end
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
        it "returns 204" do
          subject
          expect(response.status).to eq 204
        end
        include_examples 'update post parameter', 'name', 'new user'
      end

      context 'with valid title attribute' do
        subject do
          post :create,
          id: post.id,
          post: attributes_for(:post, title: 'new title'),
          format: :json
        end
        it "returns 204" do
          subject
          expect(response.status).to eq 204
        end
        include_examples 'update post parameter', 'title', 'new title'
      end

      context 'with valid content attribute' do
        subject do
          post :create,
          id: post.id,
          post: attributes_for(:post, content: 'new content'),
          format: :json
        end
        it "returns 204" do
          subject
          expect(response.status).to eq 204
        end
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
        it "returns 302" do
          subject
          expect(response.status).to eq 302
        end
        include_examples 'update post parameter', 'name', 'new user'
      end

      context 'with valid title attribute' do
        subject { post :create, id: post.id, post: attributes_for(:post, title: 'new title') }
        it "returns 302" do
          subject
          expect(response.status).to eq 302
        end
        include_examples 'update post parameter', 'title', 'new title'
      end

      context 'with valid content attribute' do
        subject { post :create, id: post.id, post: attributes_for(:post, content: 'new content') }
        it "returns 302" do
          subject
          expect(response.status).to eq 302
        end
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

        it "returns 204" do
          subject
          expect(response.status).to eq 204
        end

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

        it "returns 302" do
          subject
          expect(response.status).to eq 302
        end

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
