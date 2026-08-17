Deface::Override.new(
  virtual_path: "spree/checkout/complete",
  name: "remove_ship_address_phone",
  remove: "erb[loud]:contains('@order.ship_address.phone')",
  original: "<%= @order.ship_address.phone %>"
)

Deface::Override.new(
  virtual_path: "spree/checkout/complete",
  name: "remove_bill_address_phone",
  remove: "erb[loud]:contains('@order.bill_address.phone')",
  original: "<%= @order.bill_address.phone %>"
)
