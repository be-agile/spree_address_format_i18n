# Configure Spree Address Format I18n
SpreeAddressFormatI18n.configure do |config|
  # Address fields order by locale
  config.address_fields_order = {
    'ja' => [:lastname, :firstname, :zipcode, :state, :city, :address1, :address2, :phone]
    # 'ja_with_kana' は自動的に追加されます（カナフィールドを追加した場合）
  }
end
