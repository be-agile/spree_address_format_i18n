module SpreeAddressFormatI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def ask_for_kana_fields
        if ['', 'y', 'Y'].include?(ask('Would you like to add kana fields to address? [Y/n]'))
          generate 'spree_address_format_i18n:add_kana_fields'
        end
      end
    end
  end
end
