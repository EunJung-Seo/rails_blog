# Comment Controller
class CommentsController < ApplicationController
  before_filter :find_post_by_id
  before_filter :find_comment_by_id, only: [:destroy]

  def create
    @comment = @post.comments.create(params[:comment])
    redirect_to post_path(@post)
  end

  def destroy
    @comment.destroy
    redirect_to post_path(@post)
  end

  # ===============================================================
  #
  #                         PRIVATE
  #
  # ===============================================================

  private

  def find_post_by_id
    @post = Post.find_by_id(params[:post_id])
    if @post.blank?
      respond_to do |format|
        format.html { redirect_to posts_url }
        format.json { render json: { error: 'Post not found' }, status: :unprocessable_entity }
      end
    end
  end

  def find_comment_by_id
    @comment = @post.comments.find(params[:id])
    if @comment.blank?
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.json { render json: { error: 'Comment not found' }, status: :unprocessable_entity }
      end
    end
  end
end
