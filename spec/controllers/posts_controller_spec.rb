# -*- encoding : utf-8 -*-
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                           SHARED EXAMPLES
  #
  # ===============================================================

  shared_examples 'return status code' do |code|
    it "returns status code #{code}" do
      subject
      expect(response.status).to eq code
    end
  end

  shared_examples 'return error message' do |attribute, message|
    it "returns a error message" do
      subject
      expect(JSON.parse(response.body)[attribute][0]).to eq message
    end
  end

  shared_examples 'render template' do |action|
    it "renders #{action} template" do
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

      include_examples 'return status code', 200

      it 'returns posts' do
        subject
        expect(response.body).to eq post_list.to_json
      end
    end

    context 'when respond format is html' do
      subject { get :index }

      include_examples 'return status code', 200

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

        include_examples 'return status code', 200

        it 'returns the post' do
          subject
          expect(JSON.parse(response.body)['title']).to eq 'New! 새글!'
        end
      end

      context 'with invalid id' do
        subject { get :show, id: -10, format: :json }
        include_examples 'return status code', 422

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Post not found'
        end
      end
    end

    describe 'html' do
      context 'with valid id' do
        subject { get :show, id: post.id }

        include_examples 'return status code', 200

        it 'assigns post to @post' do
          subject
          expect(assigns(:post)).to eq post
        end

        include_examples 'render template', 'show'
      end

      context 'with invalid id' do
        subject { get :show, id: -10 }
        include_examples 'return status code', 302

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

        include_examples 'return status code', 201

        it "has a default values" do
          subject
          expect(JSON.parse(response.body)).to include request.params['post']
        end
      end

      context 'when name is nil' do
        subject { post :create, post: attributes_for(:invalid_post_name), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'name', "can't be blank"
      end

      context 'when title is nil' do
        subject { post :create, post: attributes_for(:invalid_post_title), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', "can't be blank"
      end

      context 'when title is shorter than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', 'is too short (minimum is 5 characters)'
      end

      context 'when title is longer than 10 characters' do
        subject { post :create, post: attributes_for(:long_post_title), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', 'is too long (maximum is 10 characters)'
      end

      context 'when title has prohibited words' do
        subject { post :create, post: attributes_for(:wrong_title), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', "제목에 들어갈 수 없는 단어가 있습니다 : title"
      end

      context "when content is nil" do
        subject { post :create, post: attributes_for(:invalid_content), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'content', "can't be blank"
      end

      context "when content does not contain expected words" do
        subject { post :create, post: attributes_for(:wrong_content), format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'content', "내용에 빠진 단어가 있습니다 : 어제, 오늘, 내일"
      end
    end

    describe 'html' do
      context 'with valid attributes' do
        subject { post :create, post: attributes_for(:post) }

        include_examples 'return status code', 302

        it "has default vaues" do
          subject
          expect(assigns[:post].as_json).to include request.params['post']
        end
      end

      context 'when name is nil' do
        subject { post :create, post: attributes_for(:invalid_post_name) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
      end

      context 'when title is nil' do
        subject { post :create, post: attributes_for(:invalid_post_title) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
      end

      context 'when title is shorter than 5 characters' do
        subject { post :create, post: attributes_for(:short_post_title) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
      end

      context 'when title is longer than 10 characters' do
        subject { post :create, post: attributes_for(:long_post_title) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
      end

      context 'when title has permitted words' do
        subject { post :create, post: attributes_for(:wrong_title) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
      end

      context "when content is nil" do
        subject { post :create, post: attributes_for(:invalid_content) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
      end

      context "when content does not contain expected words" do
        subject { post :create, post: attributes_for(:wrong_content) }

        include_examples 'return status code', 200
        include_examples 'render template', 'new'
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

        include_examples 'return status code', 204

        it "changes post's attributes" do
          subject
          expect(post.reload.as_json).to include request.params['post']
        end
      end

      context 'when name is nil' do
        subject { put :update, id: post.id, post: { 'name' => nil }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'name', "can't be blank"
      end

      context 'when title is nil' do
        subject { put :update, id: post.id, post: { 'title' => nil }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', "can't be blank"
      end

      context 'when title is shorter than 5 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'a' }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', 'is too short (minimum is 5 characters)'
      end

      context 'when title is longer than 10 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'longer than 10 characters' }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', 'is too long (maximum is 10 characters)'
      end

      context 'when title has permitted words' do
        subject { put :update, id: post.id, post: { 'title' => 'title' }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'title', "제목에 들어갈 수 없는 단어가 있습니다 : title"
      end

      context "when content is nil" do
        subject { put :update, id: post.id, post: { 'content' => nil }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'content', "can't be blank"
      end

      context "when content does not contain expected words" do
        subject { put :update, id: post.id, post: { 'content' => 'content' }, format: :json }

        include_examples 'return status code', 422
        include_examples 'return error message', 'content', "내용에 빠진 단어가 있습니다 : 어제, 오늘, 내일"
      end

      context 'with invalid id' do
        subject do
          put :update,
          id: 0,
          post: attributes_for(:post),
          format: :json
        end

        include_examples 'return status code', 422
        it 'returns a error message' do
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

        include_examples 'return status code', 302

        it "changes post's attributes" do
          subject
          expect(post.reload.as_json).to include request.params['post']
        end
      end

      context 'when name is nil' do
        subject { put :update, id: post.id, post: { 'name' => nil } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
      end

      context 'when title is nil' do
        subject { put :update, id: post.id, post: { 'title' => nil } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
      end

      context 'when title is shorter than 5 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'a' } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
      end

      context 'when title is longer than 10 characters' do
        subject { put :update, id: post.id, post: { 'title' => 'longer than 10 characters' } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
      end

      context 'when title has permitted words' do
        subject { put :update, id: post.id, post: { 'title' => 'title 제목' } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
      end

      context "when content is nil" do
        subject { put :update, id: post.id, post: { 'content' => nil } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
      end

      context "when content does not contain expected words" do
        subject { put :update, id: post.id, post: { 'content' => 'content' } }

        include_examples 'return status code', 200
        include_examples 'render template', 'edit'
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
        context 'when destroy successed' do
          subject { delete :destroy, id: post.id, format: :json }

          include_examples 'return status code', 204
          it 'removes the post' do
            subject
            expect(Post.find_by_id(post.id)).to eq nil
          end
        end
        context 'when destroy failed' do
          before(:each) do
            allow(Post).to receive(:find_by_id).and_return(post)
            allow(post).to receive(:destroy).and_return(false)
          end
          subject { delete :destroy, id: post.id, format: :json}

          include_examples 'return status code', 417
          it 'returns error message' do
            subject
            expect(JSON.parse(response.body)['error']).to eq 'Failed to destroy'
          end
        end
      end

      context 'with invalid id' do
        subject { delete :destroy, id: 0, format: :json }

        include_examples 'return status code', 422

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error']).to eq 'Post not found'
        end
      end
    end

    describe 'html' do
      context 'with valid id' do
        context 'when destroy successed' do
          subject { delete :destroy, id: post.id }

          include_examples 'return status code', 302
          it 'redirects to index' do
            subject
            expect(response).to redirect_to(posts_url)
          end

          it 'removes the post' do
            subject
            expect(Post.find_by_id(post.id)).to eq nil
          end
        end

        context 'when destroy failed' do
          before(:each) do
            allow(Post).to receive(:find_by_id).and_return(post)
            allow(post).to receive(:destroy).and_return(false)
          end
          subject { delete :destroy, id: post.id }

          include_examples 'return status code', 302
          it 'redirects to index' do
            subject
            expect(response).to redirect_to(posts_url)
          end
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
