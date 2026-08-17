class AddCompanyKanaAndFaxToSpreeAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column "spree_addresses", :company_kana, :string unless column_exists?("spree_addresses", :company_kana)
    add_column "spree_addresses", :fax, :string unless column_exists?("spree_addresses", :fax)
  end
end
