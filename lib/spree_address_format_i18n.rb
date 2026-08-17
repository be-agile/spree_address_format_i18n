require 'spree_core'
require 'spree_address_format_i18n/engine'
require 'spree_address_format_i18n/version'
require 'spree_address_format_i18n/configuration'
require 'deface'

module SpreeAddressFormatI18n
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    alias :config :configuration
  end

  Config = configuration
end
