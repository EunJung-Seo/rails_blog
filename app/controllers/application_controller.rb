class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def find_post_by_id
    @post = Post.find_by_id(params[:id])
    if @post.blank?
      respond_to do |format|
        format.html { redirect_to posts_url }
        format.json { render json: { error: 'Post not found' }, status: :unprocessable_entity }
      end
    end
  end
end
