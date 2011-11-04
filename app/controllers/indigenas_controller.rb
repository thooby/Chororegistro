class IndigenasController < ApplicationController
  before_filter :login_required
  def index
    list
    render :action => 'list'
  end

  def list
    @indigena_pages, @indigenas = paginate :indigena, :per_page => 10
  end

  def show
    @indigena = Indigena.find(params[:id])
  end

  def new
    @indigena = Indigena.new
  end

  def create
    @indigena = Indigena.new(params[:indigena])
    if @indigena.save
      flash['notice'] = 'Indigena was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @indigena = Indigena.find(params[:id])
  end

  def update
    @indigena = Indigena.find(params[:id])
    if @indigena.update_attributes(params[:indigena])
      flash['notice'] = 'Indigena was successfully updated.'
      redirect_to :action => 'show', :id => @indigena
    else
      render :action => 'edit'
    end
  end

  def destroy
    Indigena.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
