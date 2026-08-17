module SpreeAddressFormatI18n
  module AddressDecorator
    FIELDS_TO_NORMALIZE = [ "phone", "alternative_phone", "zipcode" ]

    def self.prepended(base)
      base.before_validation :remove_emoji_and_normalize

      base.const_set(:ADDRESS_FIELDS, %w[firstname lastname firstname_kana lastname_kana company address1 address2 city state zipcode country phone fax company_kana])

      # カナ presence は「新規入力」または「このリクエストでカナを変更したとき」のみ要求する。
      # use_kana_fields を後から有効化したストアには、カナ未登録の既存住所が多数存在する
      # (実運用のストアでは3割を超えることもある)。これらは clone_shipping_address で bill=ship として再検証される
      # 際に空のままなので、無条件 presence だと既存ユーザーがチェックアウトできなくなる。
      # 永続済み・未変更の空カナはスキップし、新規 or ユーザーが明示的にカナを変更/クリアした
      # 場合のみ必須にすることで、データ品質(新規は必須)と既存ユーザーの購入可否を両立する。
      # @see https://github.com/be-agile/giga-repeat/issues/1210
      kana_presence_required = lambda do |address, field|
        next false unless Spree::Store.current.use_kana_fields
        address.new_record? || address.public_send(:"#{field}_changed?")
      end

      # セイ（lastname_kana）を先に定義してエラーメッセージの順序を制御
      base.validates :lastname_kana, presence: true, if: -> { kana_presence_required.call(self, :lastname_kana) }
      base.validates :lastname_kana, format: { with: /\A[\p{Katakana}\p{Blank}ー・]+\z/, allow_blank: true, message: :invalid_katakana }, if: -> { Spree::Store.current.use_kana_fields }

      # メイ（firstname_kana）
      base.validates :firstname_kana, presence: true, if: -> { kana_presence_required.call(self, :firstname_kana) }
      base.validates :firstname_kana, format: { with: /\A[\p{Katakana}\p{Blank}ー・]+\z/, allow_blank: true, message: :invalid_katakana }, if: -> { Spree::Store.current.use_kana_fields }

      base.validates :company_kana, format: { with: /\A[\p{Katakana}\p{Blank}ー・]+\z/ }, if: -> { company_kana.present? }
    end


    # @gem-override spree_core-5.3.6/app/models/spree/address.rb#to_s
    # @see https://github.com/be-agile/giga-repeat/commit/c1a9869799d490211889807bc603fe7c94ea66dc
    # 本家の固定フォーマットではなく、i18n の groups 定義に沿った日本語住所表記で組む。
    def to_s
      # texts.reject(&:blank?).join("<br/>").html_safe
      safe_texts = texts.reject(&:blank?).map do |text|
        ERB::Util.html_escape(text.to_s)
      end
      # rubocop:disable Rails/OutputSafety
      safe_texts.join("<br/>").html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def to_text
      texts.reject(&:blank?).join("\n")
    end

    def oneline
      texts.join(" ")
    end

    def texts
      delimiter = I18n.t("address_format_i18n.delimiter", default: " ")
      groups = I18n.t('address_format_i18n.groups').deep_dup
      field_suffixes = I18n.t('address_format_i18n.field_suffixes', default: {})

      unless Spree::Store.current.use_kana_fields
        fn_group = groups.find { |group| group[:name] == 'fn' }
        fn_group[:fields] = fn_group[:fields].reject { |field| field.include?('kana') }
      end

      result = groups.flat_map do |group|
        nodes = group[:children] || [ group ]

        nodes.map do |node|
          # show_country_fieldがfalseの場合、countryフィールドを除外
          visible_fields = node[:fields].dup
          visible_fields.reject! { |field| field.to_s == 'country' } unless Spree::Store.current.show_country_field

          # 名前グループの特別処理（カナがある場合）
          if group[:name] == 'fn' && Spree::Store.current.use_kana_fields
            line = format_name_with_kana(visible_fields, delimiter)
          else
            field_values = visible_fields.filter_map { |field| respond_to?(field) ? send(field) : nil }
            line = field_values.join(delimiter) if field_values.present?
          end

          if line.present?
            # グループに接尾辞が設定されている場合は追加
            suffix = field_suffixes[group[:name].to_sym] || field_suffixes[group[:name]]
            line += " #{suffix}" if suffix
            line
          end
        end
      end
    end

    # @gem-override spree_core-5.3.6/app/models/spree/address.rb#full_name
    # @see https://github.com/be-agile/giga-repeat/commit/c1a9869799d490211889807bc603fe7c94ea66dc
    # 本家 `"#{firstname} #{lastname}"` ではなく、i18n の名前順・接尾辞（様 等）を反映する。
    def full_name
      field_suffixes = I18n.t('address_format_i18n.field_suffixes', default: {})

      name = I18n.t("address_format_i18n.address.full_name", default: [ "firstname", "lastname" ])
        .map { |part| send(part) if respond_to?(part) }
        .compact.join(" ").strip

      # fnグループの接尾辞があれば追加
      suffix = field_suffixes['fn'] || field_suffixes[:fn]
      name += " #{suffix}" if suffix && name.present?

      name
    end

    private

    def remove_emoji_and_normalize
      attributes_to_normalize = attributes.slice(*FIELDS_TO_NORMALIZE)
      normalized_attributes = attributes_to_normalize.compact_blank.deep_transform_values do |value|
        NormalizeString.remove_emoji_and_normalize(value.to_s).strip
      end

      normalized_attributes.transform_keys! { |key| key.gsub('original_', '') } if defined?(Spree::Security::Addresses)

      assign_attributes(normalized_attributes)
    end

    def format_name_with_kana(fields, delimiter)
      # 漢字とカナのフィールドを分離
      kanji_fields = fields.reject { |field| field.include?('kana') }
      kana_fields = fields.select { |field| field.include?('kana') }

      # 漢字名を取得
      kanji_values = kanji_fields.filter_map { |field| respond_to?(field) ? send(field) : nil }
      return nil if kanji_values.blank?

      kanji_name = kanji_values.join(delimiter)

      # カナ名を取得（両方空でない場合のみ）
      kana_values = kana_fields.filter_map { |field| respond_to?(field) ? send(field) : nil }

      if kana_values.present? && kana_values.any?(&:present?)
        kana_name = kana_values.join('')  # カナはスペースなしで連結
        "#{kanji_name}(#{kana_name})"
      else
        kanji_name
      end
    end
  end
end

Spree::Address.prepend(SpreeAddressFormatI18n::AddressDecorator)
