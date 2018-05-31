class PagesController < ApplicationController
  before_action :require_login, only: [:admin, :profile]
  before_action :require_admin, only: [:admin]

  def index
    set_all_items
    set_user
    set_cart
  end

  def about
    set_all_items
    set_user
  end

  def admin
    set_all_items
    set_user
    set_all_users
  end

  def profile
    set_user
  end

end
