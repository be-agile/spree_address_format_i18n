module SpreeAddressFormatI18n
  module PermittedAttributesDecorator
    def self.prepended(base)
      base.address_attributes.push(:firstname_kana, :lastname_kana, :company_kana, :fax)
    end
  end
end

Spree::PermittedAttributes.prepend(SpreeAddressFormatI18n::PermittedAttributesDecorator)
