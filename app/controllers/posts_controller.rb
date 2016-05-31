class PostsController < ApplicationController
  before_filter :find_post_by_id, only: [:show, :edit, :update, :destroy]
  before_filter :check_post_validation, only: [:create, :update]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      @post.save
      format.html { redirect_to @post, notice: 'Post was successfully created.' }
      format.json { render json: @post, status: :created, location: @post }
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    respond_to do |format|
      @post.update_attributes(params[:post])
      format.html { redirect_to @post, notice: 'Post was successfully updated.' }
      format.json { head :no_content }
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    respond_to do |format|
      @post.destroy
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  # ===============================================================
  #
  #                         PRIVATE
  #
  # ===============================================================

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

  def check_post_validation
    unless Post.new(params[:post]).valid?
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.json { render json: { error: 'Invalid Post' }, status: :unprocessable_entity }
      end
    end
  end
end
