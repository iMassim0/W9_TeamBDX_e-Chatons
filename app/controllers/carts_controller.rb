class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :edit, :update, :destroy, :index, :add_to_cart, :delete_to_cart, :calcul_total]
  # GET /carts
  # before_action :require_login, only: [:show, :edit, :update, :destroy, :index, :add_to_cart, :delete_to_cart]


  # GET /carts.json
  def index
      @user = current_user
      if Cart.where(user: @user)
        @total = calcul_total
      end
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
    @item = Item.all.find_by(id: params[:id])
      respond_to do |f|
        f.js   { render :layout => false }
        f.html { redirect_to root_url }
        f.json { head :no_content }
      end

  end

  # GET /carts/new
  def new
    @cart = Cart.new
  end

  # GET /carts/1/edit
  def edit
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)

    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
        format.json { render :show, status: :created, location: @cart }
      else
        format.html { render :new }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = current_user
    calcul_total
    update_params
    @item = @cart.cart_items.where(added_item: params[:id]).last
    @item.quantity = params[:item][:quantity]
      if @item.save
        render 'index'
      else
        flash[:error] = "Erreur de modification"
        render 'index'
      end
  end


  def destroy
    @cart.added_items.delete(set_item)
    respond_to do |format|
      format.html { redirect_to mon_panier_path, notice: 'Cart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_to_cart
    set_item
    if @cart.added_items << @item
      flash[:success] = "Element ajouté à votre panier"
      redirect_to root_path
    end
  end

  def delete_to_cart
    @cart = Cart.find(cart_params[:cart])
    @item = CartItem.find(cart_params[:item])
    @cart.cart_items.destroy(@item)
    redirect_to mon_panier_path
  end

  def calcul_total
    @total = 0
    @cart.added_items.each do |item|
      @total += ((item.price).round * @cart.cart_items.find_by(added_item: item).quantity.to_i)
    end
    return @total
  end

    def payment
      set_cart
      set_user
      calcul_total
      new_charge
      if @charge.save
        redirect_to new_order_path
      else
        flash[:error] = "Problème de paiement"
        redirect_to mon_panier_path
      end
    end

  def new_charge
    Stripe.api_key = ENV['STRIPE_SECRET']
    token = params.require(:stripeToken)

    @charge = Stripe::Charge.create({
        amount: (@total*100).to_i,
        currency: 'eur',
        description: "User #{@user.id}, order n°#{@cart.id}",
        source: token,
    })
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_cart
    #   if user_signed_in? && current_user.cart
    #     @cart = current_user.cart
    #   elsif user_signed_in?
    #     @cart = Cart.create(user: current_user)
    #   elsif @cart = Cart.find_by(id: session[:cart_id])
    #   else
    #     flash[:error] = "Merci de vous connecter pour accéder à cette page."
    #     redirect_to new_user_session_path
    #     # p session[:session_id]
    #     # @cart = Cart.create(user: session[:session_id])
    #     # session[:cart_id] = @cart.id
    #   end
    # end
    #
    # def set_cart
    #   if @cart = Cart.find_by(session: session[:cart])
    #     if !@cart.user && user_signed_in?
    #         current_user.cart.destroy
    #         @cart.update(user: current_user, session: nil)
    #     end
    #   elsif user_signed_in? && current_user.cart
    #     @cart = current_user.cart
    #   else
    #     session[:cart] = SecureRandom.base64(10)
    #     @cart = Cart.create(session: session[:cart])
    #   end
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_params
      params.permit(:cart, :item)
    end

    def update_params
      params.require(:item).permit(:id, :quantity)
    end

end
