module Spree
  module AddressesHelperDecorator
    # List of kana fields that should not be excluded even when `store.use_kana_fields` is false.
    IGNORED_KANA_FIELDS = [ :company_kana ]

    # @gem-override spree_core-5.3.6/app/helpers/spree/addresses_helper.rb#address_field
    # @see https://github.com/be-agile/giga-repeat/issues/1397
    # 本家を super で呼び、入力欄の直下にその欄のエラーを足し、placeholder を入力例にする
    # (引数リストは本家のシグネチャに依存する)。本家はエラーをページ最上部の一覧にしか
    # 出さないため、入力欄から遠くて気づかれない。
    def address_field(form, method, address_id = 'b', required = false, text_field_attributes: {}, &handler)
      label = I18n.t("activerecord.attributes.spree/address.#{method}")
      field = super(form, method, address_id, required, text_field_attributes: text_field_attributes.merge(placeholder: address_placeholder(method, label)), &handler)
      field + address_field_errors(form, method)
    end

    # @gem-override spree_core-5.3.6/app/helpers/spree/addresses_helper.rb#address_zipcode
    # @see https://github.com/be-agile/giga-repeat/issues/1397
    # placeholder を入力例にする以外は本家のまま。
    def address_zipcode(form, country, address_id = 'b')
      method_name = Spree.t(:zipcode)
      form.label(:zipcode, method_name, id: address_id + '_zipcode_label', class: 'block text-xs text-neutral-600 mb-1') +
      form.text_field(:zipcode,
                      class: 'text-input',
                      placeholder: address_placeholder(:zipcode, method_name),
                      required: country&.zipcode_required?,
                      data: { 'address-form-target': 'zipcode', address_autocomplete_target: 'zipcode' },
                      aria: { label: Spree.t(:zipcode) })
    end

    # 入力例(spree.address_placeholders.*)が無いロケール・欄では、本家と同じくラベル名を使う。
    def address_placeholder(method, label)
      I18n.t("spree.address_placeholders.#{method}", default: label)
    end

    def address_field_errors(form, method)
      safe_join(form.object.errors.full_messages_for(method).map do |message|
        content_tag(:p, message, class: 'text-red-500 text-xs mt-1')
      end)
    end

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
