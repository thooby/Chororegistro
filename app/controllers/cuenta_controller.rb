class CuentaController < ApplicationController
  layout  'scaffold'

  def login
    case request.method
      when :post
      if session[:user] = User.authenticate(params[:user_login], params[:user_password])

        flash['notice']  = "Identificado correctamente"
        redirect_back_or_default :action => "welcome"
      else
        flash.now['notice']  = "usuario y/o password no correctos"

        @login = params[:user_login]
      end
    end
  end
  
  def signup
    @user = User.new(params[:user])

    if request.post? and @user.save
      session[:user] = User.authenticate(@user.login, params[:user][:password])
      flash['notice']  = "Identificado correctamente"
      redirect_back_or_default :action => "welcome"
    end      
  end  
  
  def logout
    session[:user] = nil
  end
    
  def welcome
  end
  
end
