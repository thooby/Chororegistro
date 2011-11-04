
class PersonasController < ApplicationController
  def index
    list
    render(:action => 'list')
  end 

  def list
    @alfaorig = Array.new(26) {|i| (i+65).chr}
    @alfabeto = Array.new(26) {|i| (i+65).chr}
    @orden = Persona.find(:all, :order => "apellido1")
    @orden.collect!{|x| x.apellido1[0].chr.upcase if x.apellido1[0]}
    @alfabeto.collect!{|x|  (@orden.index(x).to_i/10)+1 if @orden.index(x)}
    @tipoorden = "ape"
    @cadena = ""
    @personas = Persona.paginate(:page => params[:page], :per_page =>10,
          :order => 'apellido1, apellido2, nombre')
    @zonas = Zona.find(:all)
  end
  def buscon
      render(:action => 'buscon')
  end    
  def buscar_d
    @elegidas = Persona.find(:all)
  end    
  def buscar_zona
    identzona = params[:persona][:zona_id]
    @elegidas = Persona.find(:all, :conditions => ["zona_id = ?",identzona], :order => 'apellido1, apellido2, nombre')
    @numero = @elegidas.length
    render(:action =>'elist')
  end  

  def buscar_acta
    @cadena1 = params[:actabusca]
    nacta = @cadena1.to_i
    @elegidas = Persona.find(:all, :conditions => ["acta = ?",nacta])
    render(:action => 'elist')
  end  
  def buscar
    @cadena = params[:textobusca]
    @flexi = params[:flexi]  
    if @flexi=="T" 
         @elegidas = Persona.search @cadena
    else
         @elegidas = Persona.search2 @cadena
    end

    render(:action => 'elist')
  end  

    def list_by_zona
    @alfaorig = Array.new(26) {|i| (i+65).chr}
    @alfabeto = Array.new(26) {|i| (i+65).chr}
    orden=Persona.find(:all).collect{|x| (x.zona.ubicacion[0].chr.upcase if x.zona.ubicacion[0]) or ' '}.sort
    @alfabeto.collect!{|x|  (orden.index(x).to_i/10)+1 if orden.index(x)}
    @personas = Persona.paginate(:page => params[:page], :per_page =>10,
          :include => :zona,
          :order => 'zonas.ubicacion, apellido1, apellido2, nombre')
    @tipoorden = "zon"
    render :action => 'list'
  end
    def list_by_acta
    @ntomoori = [2, 3, 4, 5, 6, 7, 10, 13, 14, 1974, 1999]
    @ntomo = [2, 3, 4, 5, 6, 7, 10, 13, 14, 1974, 1999]
    @ordentomo = Persona.find(:all, :order => "tomo")
    @ordentomo.collect!{|x| x.tomo if x.tomo}
    @ntomo.collect!{|x|  (@ordentomo.index(x).to_i/10)+1 if @ordentomo.index(x)}
    @cadena = ""
    @personas = Persona.paginate(:page => params[:page], :per_page =>10,
          :order => 'tomo, acta,apellido1, apellido2, nombre')
    @tipoorden = "tom"
    render :action => 'list'
  end

  def show
    @persona = Persona.find(params[:id])
    @zona = Zona.find(@persona[:zona_id])
    @ttipoorden = params[:tipoorden]
    if params[:tipoorden]=="ape"
       @orden = Persona.find(:all, :order => "apellido1, apellido2, nombre")
    else
       @orden = Persona.find(:all, :order => "tomo, acta, apellido1, apellido2, nombre")
    end
    @orden.collect!{|x| x.id }
    @pagina = (@orden.index(@persona.id).to_i/10)+1 
  end

  def new
    @indigenas = Indigena.find(:all)
    @zonas = Zona.find(:all)
    @vives = Vive.find(:all)
    @persona = Persona.new
  end
  def rellena
    @indigenas = Indigena.find(:all)
    @zonas = Zona.find(:all)
    @vives = Vive.find(:all)
    @persona = Persona.new
  end

  def create
    @persona = Persona.new(params[:persona])
    if @persona.save
      flash['notice'] = 'Los datos de esta persona fueron añadidos.'
      redirect_to :action =>  'show', :id => @persona 
    else
      render :action => 'new'
    end
  end

  def edit
    @indigenas = Indigena.find(:all)
    @zonas = Zona.find(:all)
    @vives = Vive.find(:all)
    @persona = Persona.find(params[:id])
    @ttipoorden = params[:tipoorden]
  end

  def update
    @persona = Persona.find(params[:id])
    @ttipoorden = params[:tipoorden]
    if @persona.update_attributes(params[:persona])
      flash['notice'] = 'Los datos de esta  persona fueron actualizados.'
      redirect_to( :action =>  'show', :tipoorden => @ttipoorden, :id => @persona.id )
    else
      render(:action => 'edit')
    end
  end

  def parecidos
    @persona = Persona.find(params[:id])
    @elegidas = Votante.find(:all, :conditions => ["upper(translate(apellido1,'zaeiouáéíóú','s'))= upper(translate(?,'zaeiouáéíóú','s')) and  upper(translate(apellido2,'zaeiouáéíóú','s'))=upper(translate(?,'zaeiouáéíóú','s'))",@persona.apellido1,@persona.apellido2])
    render :action => 'elistp'
  end

  def destroy
    Persona.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
