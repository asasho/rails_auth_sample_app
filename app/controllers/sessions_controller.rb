class SessionsController < ApplicationController
  
  #GET /login
  def new
    # x @session = Session.new
    # o scope: :session + url: login_path
  end
  
  #POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        #Success
        # ユーザーログイン後にユーザー情報のページにリダイレクトする
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forgot(user)
        redirect_back_or user
      else
        message = "Account not activated."
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      #Failure
      flash.now[:danger] = 'Invalid email?password combination'
      render 'new'
      # redirect_to .vs render
      # GET /users/1 => show template
      #                 render 'new' (0回)
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
