class AddSessionToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :session, :string
  end
end
