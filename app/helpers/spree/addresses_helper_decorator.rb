module Spree
  module AddressesHelperDecorator
    # List of kana fields that should not be excluded even when `store.use_kana_fields` is false.
    IGNORED_KANA_FIELDS = [ :company_kana ]

    def order_address_fields(store)
      name_order = I18n.t('address_format_i18n.fields')
      return Spree::Address::ADDRESS_FIELDS if name_order.blank?

      fields = filter_address_fields(Spree::Address::ADDRESS_FIELDS, store)

      # Filter out kana fields if use_kana_fields is false
      unless store.use_kana_fields
        fields = fields.reject { |field| field.include?('kana') }
      end

      fields.sort_by do |field|
        name_order.index(field) || Float::INFINITY
      end
    end

    def order_address_groups(store)
      groups = I18n.t('address_format_i18n.groups').deep_dup
      unless store.use_kana_fields
        fn_group = groups.find { |group| group[:name] == 'fn' }
        fn_group[:fields] = fn_group[:fields].reject { |field| field.include?('kana') }
      end
      groups
    end

    def order_account_edit
      I18n.t('address_format_i18n.account.profile', default: %w[last_name first_name phone email])
    end

    private

    def filter_address_fields(fields, store)
      return fields if store.use_kana_fields

      fields.reject do |field|
        field.include?('kana') && !IGNORED_KANA_FIELDS.include?(field.to_sym)
      end
    end
  end

  Spree::AddressesHelper.prepend(AddressesHelperDecorator)
end
