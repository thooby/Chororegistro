class VivesController < ApplicationController
  before_filter :login_required
  def index
    list
    render :action => 'list'
  end

  def list
    @vive_pages, @vives = paginate :vive, :per_page => 10
  end

  def show
    @vive = Vive.find(params[:id])
  end

  def new
    @vive = Vive.new
  end

  def create
    @vive = Vive.new(params[:vive])
    if @vive.save
      flash['notice'] = 'Vive was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @vive = Vive.find(params[:id])
  end

  def update
    @vive = Vive.find(params[:id])
    if @vive.update_attributes(params[:vive])
      flash['notice'] = 'Vive was successfully updated.'
      redirect_to :action => 'show', :id => @vive
    else
      render :action => 'edit'
    end
  end

  def destroy
    Vive.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
