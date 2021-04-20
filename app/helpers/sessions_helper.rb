module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end
  
  #ユーザのセッションを永続的にする
  def remember(user)
      user.remember
      cookies.permanent.signed[:user_id] = user.id
      cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
      #DBの問い合わせの数を可能な限り小さくしたい
      # user_id = session[:user_id]
      # if user_id
      if (user_id = session[:user_id]) #代入したuser_idがnilかどうか
          @current_user ||= User.find_by(id: session[:user_id])
      elsif (user_id = cookies.signed[:user_id])
          user = User.find_by(id: user_id)
          if user && user.authenticated?(:remember, cookies[:remember_token])
              log_in user
              @current_user = user
          end
      end
  end
  
  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
      !current_user.nil?
  end
  
  #永続セッションを破棄する
  def forget(user)
      user.forget
      cookies.delete(:user_id)
      cookies.delete(:remember_tooken)
  end
  
  #現在のユーザをログアウトする
  def log_out
      forget(current_user)
      session.delete(:user_id)
      @current_user = nil
  end
  
  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
  
end
