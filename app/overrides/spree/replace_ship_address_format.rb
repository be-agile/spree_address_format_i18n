Deface::Override.new(
  virtual_path: 'spree/checkout/edit',
  name: 'replace_ship_address_format',
  replace: "erb[loud]:contains('@order.ship_address.to_s.gsub')",
  text: "<%= @order.ship_address.to_s.gsub('<br/>', I18n.t('address_format_i18n.delimiter', default: ' ')).html_safe %>"
)
