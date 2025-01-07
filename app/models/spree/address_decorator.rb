module Spree
  module AddressDecorator
    def self.prepended(base)
      name_order = I18n.t('address_format_i18n') || []

      sorted_fields = Spree::Address::ADDRESS_FIELDS.sort_by do |field|
        name_order.index(field) || Float::INFINITY
      end
      base.const_set(:ADDRESS_FIELDS, sorted_fields)
    end
  end

  Spree::Address.prepend(AddressDecorator)
end
