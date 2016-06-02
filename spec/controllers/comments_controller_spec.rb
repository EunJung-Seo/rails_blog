# -*- encoding : utf-8 -*-
require 'rails_helper'

describe CommentsController do
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

  shared_examples 'return alert message' do |message|
    it "returns a error message" do
      subject
      expect(flash.alert).to eq message
    end
  end
  # ===============================================================
  #
  #                              TESTS
  #
  # ===============================================================
  describe '#create' do
    let(:test_post) { create :post }
    context 'when post id is valid' do
      context 'with valid comment attribute' do
        subject { post :create, post_id: test_post.id, comment: attributes_for(:comment) }

        include_examples 'return status code', 302
        it 'redirects to post_path' do
          subject
          expect(response).to redirect_to(post_path(test_post))
        end
      end

      context 'when commenter is nil' do
        subject { post :create, post_id: test_post.id, comment: attributes_for(:invalid_commenter) }

        include_examples 'return status code', 302
        include_examples 'return alert message', '유효하지 않은 코멘트입니다.'
        it 'redirect to post_path' do
          subject
          expect(response).to redirect_to(post_path(test_post))
        end
      end

      context 'when commenter has special characters' do
        subject { post :create, post_id: test_post.id, comment: attributes_for(:invalid_commenter) }

        include_examples 'return status code', 302
        include_examples 'return alert message', '유효하지 않은 코멘트입니다.'
        it 'redirect to post_path' do
          subject
          expect(response).to redirect_to(post_path(test_post))
        end
      end

      context 'when body is nil' do
        subject { post :create, post_id: test_post.id, comment: attributes_for(:invalid_body) }

        include_examples 'return status code', 302
        include_examples 'return alert message', '유효하지 않은 코멘트입니다.'
        it 'redirect to post_path' do
          subject
          expect(response).to redirect_to(post_path(test_post))
        end
      end

      context 'when body is longer than 32 characters' do
        subject { post :create, post_id: test_post.id, comment: attributes_for(:wrong_body) }

        include_examples 'return status code', 302
        it 'redirect to post_path' do
          subject
          expect(response).to redirect_to(post_path(test_post))
        end

        include_examples 'return alert message', '유효하지 않은 코멘트입니다.'
      end
    end

    context 'when post id is invalid' do
      subject { post :create, post_id: 0, comment: attributes_for(:comment) }

      include_examples 'return status code', 302
      include_examples 'return alert message', '존재하지 않는 포스트입니다.'
      it 'redirects to index' do
        subject
        expect(response).to redirect_to(posts_url)
      end
    end
  end

  describe '#destroy' do # 포스트 id 확인 / 코멘트 id 확인
    let!(:test_post) { create(:post) }
    let!(:test_comment) { create(:comment, post: test_post) }

    context 'when post id is valid' do
      context 'with valid comment id' do
        context 'when destroy successed' do
          subject { delete :destroy, post_id: test_post.id, id: test_comment.id }

          include_examples 'return status code', 302
          it 'redirects to post_path' do
            subject
            expect(response).to redirect_to(post_path(test_post))
          end
          it 'delete a comment' do
            expect { subject }.to change(Comment, :count).by(-1)
          end
        end

        context 'when destroy failed' do
          before(:each) do
            allow(Post).to receive(:find_by_id).and_return(test_post)
            allow(test_post).to receive_message_chain(:comments, :find_by_id, :destroy).and_return(false)
          end
          subject { delete :destroy, post_id: test_post.id, id: test_comment.id }

          include_examples 'return status code', 302
          it 'redirects to the post' do
            subject
            expect(response).to redirect_to(post_path(test_post))
          end
        end
      end

      context 'with invalid comment id' do
        subject { delete :destroy, post_id: test_post.id, id: 0 }

        include_examples 'return status code', 302
        include_examples 'return alert message', '존재하지 않는 코멘트입니다.'
        it 'redirects to post_path' do
          subject
          expect(response).to redirect_to(post_path(test_post))
        end
      end
    end

    context 'when post id is invalid' do
      subject { delete :destroy, post_id: 0, id: test_comment.id }

      include_examples 'return status code', 302
      include_examples 'return alert message', '존재하지 않는 포스트입니다.'
      it 'redirects to index' do
        subject
        expect(response).to redirect_to(posts_url)
      end
    end
  end
end
