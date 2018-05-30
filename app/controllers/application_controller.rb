class ApplicationController < ActionController::Base
  include ItemsHelper

  helper_method :set_user, :set_item, :set_all_users, :calcul_total, :set_all_items, :require_admin, :require_login, :user_admin?
  before_action :configure_permitted_parameters, :set_user, if: :devise_controller?

  def require_login
    unless user_signed_in?
      flash[:error] =  "Merci de vous connecter pour accéder à cette page."
      redirect_to new_user_registration_path
    end
  end


def require_admin
  if set_user
    if !(@user.role == "admin")
      flash[:error] =  "Vous n'avez pas les droits Admin."
      redirect_to root_path
    end
  else
    require_login
  end
end


def set_user
  if current_user
    @user = current_user
  end
  return @user
end

def set_item
    @item = Item.find(params[:id])
    return @item
end

def set_all_users
  @users = User.all
  return @users
end

def set_all_items
  @items = Item.all
  return @items
end

def user_admin?
  set_user
  if @user
    if @user.role == "admin"
      return true
    else
      return false
    end
  end
end

protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname])
end

end
