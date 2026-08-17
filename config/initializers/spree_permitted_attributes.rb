module Spree
  module PermittedAttributes
    mattr_accessor :store_attributes

    @@store_attributes ||= []
    @@store_attributes += [
      :use_kana_fields
    ]
  end
end
