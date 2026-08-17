class AddKanaColumnsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column 'spree_addresses', :firstname_kana, :string unless column_exists?('spree_addresses', :firstname_kana)
    add_column 'spree_addresses', :lastname_kana, :string unless column_exists?('spree_addresses', :lastname_kana)
  end
end
