Deface::Override.new(
  virtual_path: "spree/admin/stores/form/_basic",
  name: "add_show_country_field",
  insert_before: "erb[loud]:contains('render_admin_partials')",
  partial: "spree/admin/stores/country_field_settings"
)
