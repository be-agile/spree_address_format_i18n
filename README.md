SpreeAddressFormatI18n
=====================

This extension provides:
1. Customizable address field ordering through YAML configuration
2. Japanese kana field support for addresses (firstname_kana, lastname_kana)

Install
=======

Add the following line to your application's Gemfile:

```ruby
gem "spree_address_format_i18n", :git => "https://github.com/be-agile/spree_address_format_i18n.git", :branch => 'master'
```

Run:

```bash
bundle install
bundle exec rails g spree_address_format_i18n:install
```

Configuration
============

To customize the order of address fields, create a YAML file in your application's config/locales directory:

```yaml
# config/locales/order.ja.yml
ja:
  address_format_i18n:
    - lastname
    - firstname
    - lastname_kana
    - firstname_kana
    - country
    - zipcode
    - state
    - city
    - address1
    - address2
```

The extension will use this configuration to determine the order of fields in address forms and displays. Fields not specified in the configuration will be displayed at the end in their default order.

Japanese Kana Support
====================

This extension adds support for Japanese kana fields (firstname_kana, lastname_kana) to Spree addresses. These fields are automatically added to the database when you run the migrations.

To use the kana fields:

1. Make sure you've run the migrations: `bundle exec rails g spree_address_format_i18n:install`
2. Include the kana fields in your address_format_i18n configuration (see example above)
3. The kana fields will be displayed in address forms and on address display pages according to your configuration

Validation for kana fields ensures that they contain only katakana characters.
