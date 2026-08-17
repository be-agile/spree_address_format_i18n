module SpreeAddressFormatI18n
  class Configuration
    include Spree::Preferences::Preferable

    preference :address_fields_order, :hash, default: {
      'ja' => [:lastname, :firstname, :zipcode, :state, :city, :address1, :address2, :phone]
    }
  end
end
