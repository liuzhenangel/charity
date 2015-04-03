class Admin::PostsController < ApplicationController
  layout 'admin'

  before_action do
    unless login?
      flash[:error] = '请先登录后再操作'
      redirect_to signin_path
    end
  end

  def photos
    @photo = Photo.new(image: params["Filedata"])
    @photo.save!
    render :text=> "![](#{@photo.image.url})"
  end

  def main_photo
    @mainphoto = MainPhoto.new(image: params["Filedata"])
    @mainphoto.save!
    render json: { :img => @mainphoto.image.url, :photo_id => @mainphoto.id }
  end

  def preview
    html = Markdown.new(params[:body]).to_html
    render text: html
  end

  def index
    @articles = Article.all
  end

  def edit
    @article = Article.find(params[:id])
    @main_photo = @article.main_photo
  end

  def update
    @article = Article.find(params[:id])
    @article.update(article_params)
    @article.main_photo.destroy
    photo = MainPhoto.find(params[:main_photo_id])
    photo.update(article_id: @article.id)
    redirect_to @article.to_html
  end

  def new
    @article = Article.new
    @main_photo = MainPhoto.new
  end

  def show
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      photo = MainPhoto.find(params[:main_photo_id])
      photo.update(article_id: @article.id)
      redirect_to @article
    else
      flash.now[:error] = '新增博客失败'
      render :new
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to admin_posts_path
  end

  private
  def article_params
    params.require(:article).permit(:title, :content)
  end
end
