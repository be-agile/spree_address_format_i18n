module CustomNameOfPerson
  class PersonName < NameOfPerson::PersonName
    def full
      @full ||= begin
        field_suffixes = I18n.t('address_format_i18n.field_suffixes', default: {})
        suffix = field_suffixes['fn'] || field_suffixes[:fn] || ''

        order = I18n.t("address_format_i18n.address.full_name", default: %w[first_name last_name])
        parts = order.map do |part|
          case part.to_s.downcase
          when "first_name" then first.to_s.strip
          when "last_name" then last.to_s.strip
          else nil
          end
        end.compact.join(" ").strip

        base_name = parts.blank? ? first.to_s.strip : parts
        base_name += " #{suffix}" if suffix
        base_name
      end
    end

    # to_sメソッドもオーバーライドして、デフォルトでfullを返すように
    def to_s
      full
    end
  end
end

module Spree
  module UserDecorator
    def name
      return nil if first_name.blank?

      @custom_name ||= CustomNameOfPerson::PersonName.new(first_name.to_s.strip, last_name.to_s.strip)
    end
  end
end

Spree.user_class.prepend(Spree::UserDecorator)
