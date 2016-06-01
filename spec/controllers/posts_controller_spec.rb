# -*- encoding : utf-8 -*-
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                           SHARED EXAMPLES
  #
  # ===============================================================

  shared_examples 'rendering template' do |action|
    it "reders #{action} template" do
      subject
      expect(response).to render_template(action)
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
        it "has a default values" do
          subject
          expect(JSON.parse(response.body)).to include request.params['post']
        end
      end

      context 'when name is nil' do
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

      context 'when title is nil' do
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

      context 'when title is shorter than 5 characters' do
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

      context 'when title is longer than 10 characters' do
        subject { post :create, post: attributes_for(:long_post_title), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'when title has permitted words' do
        subject { post :create, post: attributes_for(:wrong_title), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context "when content is nil" do
        subject { post :create, post: attributes_for(:invalid_content), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context "when content does not contain expected words" do
        subject { post :create, post: attributes_for(:wrong_content), format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
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
        it "has default vaues" do
          subject
          expect(assigns[:post].as_json).to include request.params['post']
        end
      end

      context 'when name is nil' do
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

      context 'when title is nil' do
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

      context 'when title is shorter than 5 characters' do
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

      context 'when title is longer than 10 characters' do
        subject { post :create, post: attributes_for(:long_post_title) }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'returns error message' do
          subject
          expect(flash.alert).to eq '유효하지 않은 포스트입니다.'
        end
      end

      context 'when title has permitted words' do
        subject { post :create, post: attributes_for(:wrong_title) }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'returns error message' do
          subject
          expect(flash.alert).to eq '유효하지 않은 포스트입니다.'
        end
      end

      context "when content is nil" do
        subject { post :create, post: attributes_for(:invalid_content) }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'returns error message' do
          subject
          expect(flash.alert).to eq '유효하지 않은 포스트입니다.'
        end
      end

      context "when content does not contain expected words" do
        subject { post :create, post: attributes_for(:wrong_content) }
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
      context 'with valid attribute' do
        subject do
          put :update,
          id: post.id,
          post: attributes_for(
            :post,
            name: 'new user',
            title: 'updated',
            content: '어제 오늘 그리고 내일'
          ),
          format: :json
        end

        it "returns 204" do
          subject
          expect(response.status).to eq 204
        end
        it "changes post's attributes" do
          subject
          expect(post.reload.as_json).to include request.params['post']
        end
      end

      context 'when name is nil' do
        subject { put :update, id: post.id, post: { 'name' => nil }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'when title is nil' do
        subject { put :update, id: post.id, post: { 'title' => nil }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'when title is shorter than 5 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'a' }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'when title is longer than 10 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'longer than 10 characters' }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context 'when title has permitted words' do
        subject { put :update, id: post.id, post: { 'title' => 'title 제목' }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context "when content is nil" do
        subject { put :update, id: post.id, post: { 'content' => nil }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
      end

      context "when content does not contain expected words" do
        subject { put :update, id: post.id, post: { 'content' => 'content' }, format: :json }
        it 'returns 422' do
          subject
          expect(response.status).to eq 422
        end
        it 'returns a error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Invalid Post'
        end
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

      context 'with valid name attribute' do
        subject do
          put :update,
          id: post.id,
          post: attributes_for(
            :post,
            name: 'new user',
            title: 'updated',
            content: '어제 오늘 그리고 내일'
          )
        end
        it "returns 302" do
          subject
          expect(response.status).to eq 302
        end
        it "changes post's attributes" do
          subject
          expect(post.reload.as_json).to include request.params['post']
        end
      end

      context 'when name is nil' do
        subject { put :update, id: post.id, post: { 'name' => nil } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end

      context 'when title is nil' do
        subject { put :update, id: post.id, post: { 'title' => nil } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end

      context 'when title is shorter than 5 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'a' } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end

      context 'when title is longer than 10 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'longer than 10 characters' } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end

      context 'when title has permitted words' do
        subject { put :update, id: post.id, post: { 'title' => 'title 제목' } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end

      context "when content is nil" do
        subject { put :update, id: post.id, post: { 'content' => nil } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
      end

      context "when content does not contain expected words" do
        subject { put :update, id: post.id, post: { 'content' => 'content' } }
        it 'returns 302' do
          subject
          expect(response.status).to eq 302
        end
        it 'redirects to index' do
          subject
          expect(response).to redirect_to(posts_url)
        end
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
    let(:post) { create(:post) }
    describe 'JSON' do
      context 'with valid id' do
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
