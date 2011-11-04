class ZonasController < ApplicationController
  def index
    list
    render(:action => :list)
  end

  def list
@zonas = Zona.paginate(:page => params[:page], :per_page =>10,
          :order => 'ubicacion')

  end

  def show
    @zona = Zona.find(params[:id])
  end

  def new
    @zona = Zona.new
  end

  def create
    @zona = Zona.new(params[:zona])
    if @zona.save
      flash['notice'] = 'Zona was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @zona = Zona.find(params[:id])
  end

  def update
    @zona = Zona.find(params[:id])
    if @zona.update_attributes(params[:zona])
      flash['notice'] = 'Zona was successfully updated.'
      redirect_to :action => 'show', :id => @zona
    else
      render :action => 'edit'
    end
  end

  def destroy
    Zona.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
