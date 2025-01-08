module Spree
  module AddressesHelperDecorator
    def order_address_fields(address_fields)
      name_order = I18n.t('address_format_i18n')
      return address_fields if name_order.blank?

      Spree::Address::ADDRESS_FIELDS.sort_by do |field|
        name_order.index(field) || Float::INFINITY
      end
    end
  end

  Spree::AddressesHelper.prepend(AddressesHelperDecorator)
end
