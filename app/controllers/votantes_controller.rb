class VotantesController < ApplicationController
  #before_filter :login_required
  def index
    list
    render :action => 'list'
  end

  def list
    @alfaorig = Array.new(26) {|i| (i+65).chr}
    @alfabeto = Array.new(26) {|i| (i+65).chr}
    @orden = Votante.find(:all, :order => "apellido1")
    @orden.collect!{|x| x.apellido1[0].chr.upcase if x.apellido1[0]}
    @alfabeto.collect!{|x|  (@orden.index(x).to_i/10)+1 if @orden.index(x)}
    @votantes = Votante.paginate(:page => params[:page], :per_page =>10,
          :order => 'apellido1, apellido2, nombre1, nombre2')

  end
  def list_by_cedula
    @cadena = ""
    @votantes = Votante.paginate(:page => params[:page], :per_page =>10,
          :order => 'cedula,apellido1, apellido2, nombre1,nombre2')
    render :action => 'list'
  end
  def list_by_direccion
    @cadena = ""
    @votantes = Votante.paginate(:page => params[:page], :per_page =>10,
          :order => 'direccion,apellido1, apellido2, nombre1,nombre2')
    render :action => 'list'
  end
  def list_by_fechanac
    @cadena = ""
    @votantes = Votante.paginate(:page => params[:page], :per_page =>10,
          :order => 'fechanac,apellido1, apellido2, nombre1,nombre2')
    render :action => 'list'
  end

  def show
    @votante = Votante.find(params[:id])
  end

  def new
    @votante = Votante.new
  end
  def buscar
    @cadena = params[:textobusca]
    @flexi = params[:flexi]
    if @flexi=="T"
         @elegidas = Votante.search @cadena
    else
         @elegidas = Votante.search2 @cadena
    end
    render :action => 'elist'
  end
  def parecidos
    @votante = Votante.find(params[:id])
    @elegidas = Persona.find(:all, :conditions => ["upper(translate(apellido1,'zaeiouáéíóú','s'))= upper(translate(?,'zaeiouáéíóú','s')) and  upper(translate(apellido2,'zaeiouáéíóú','s'))=upper(translate(?,'zaeiouáéíóú','s'))",@votante.apellido1,@votante.apellido2])
    render :action => 'elistp'
  end
  def busca_direccion
    @cadena = params[:direcbusca]
    @elegidas = Votante.search @cadena
    render :action => 'elist'
  end

  def create
    @votante = Votante.new(params[:votante])
    if @votante.save
      flash['notice'] = 'Votante was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @votante = Votante.find(params[:id])
  end

  def update
    @votante = Votante.find(params[:id])
    if @votante.update_attributes(params[:votante])
      flash['notice'] = 'Votante was successfully updated.'
      redirect_to :action => 'show', :id => @votante
    else
      render :action => 'edit'
    end
  end

  def destroy
    Votante.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
