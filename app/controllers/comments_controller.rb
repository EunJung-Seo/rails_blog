# -*- encoding : utf-8 -*-
class CommentsController < ApplicationController
  before_filter :find_post_by_id
  before_filter :check_comment_validation, only: [:create]
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
      redirect_to posts_url, alert: '존재하지 않는 포스트입니다.'
    end
  end

  def find_comment_by_id
    @comment = @post.comments.find_by_id(params[:id])
    if @comment.blank?
      redirect_to post_path(@post), alert: '존재하지 않는 코멘트입니다.'
    end
  end

  def check_comment_validation
    unless Comment.new(params[:comment]).valid?
      redirect_to post_path(@post), alert: '유효하지 않은 코멘트입니다.'
    end
  end
end
