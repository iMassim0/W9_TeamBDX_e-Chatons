class SessionsController < Devise::SessionsController

  after_action :delete_cart_cookie, :only => :destroy
  def delete_cart_cookie
    unless user_signed_in? # logout successful?
       cookies.delete(:cart)
    end
  end
end
