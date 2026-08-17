require 'active_record/typed_store'

module SpreeAddressFormatI18n
  module StoreDecorator
    def self.prepended(base)
      base.typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.boolean :use_kana_fields, default: false, null: false
        s.boolean :show_country_field, default: false, null: false
      end
    end
  end
end

Spree::Store.prepend SpreeAddressFormatI18n::StoreDecorator
