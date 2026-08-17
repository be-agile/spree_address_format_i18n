# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_address_format_i18n/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_address_format_i18n'
  s.version     = SpreeAddressFormatI18n::VERSION
  s.summary     = "Spree Commerce Address format i18n Extension"
  s.required_ruby_version = '>= 3.0'

  s.author      = 'be agile Co., Ltd.'
  s.email       = 'develop@be-agile.jp'
  s.homepage    = 'https://github.com/be-agile/spree_address_format_i18n'
  s.licenses    = ['AGPL-3.0-or-later']

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '= 5.3.6'
  s.add_dependency 'spree_admin', '= 5.3.6'
  s.add_dependency 'spree_storefront', '= 5.3.6'
  s.add_dependency 'spree_extension', '= 0.1.0'
  s.add_dependency 'deface'
  s.add_dependency 'activerecord-typedstore'

  s.add_development_dependency 'spree_dev_tools'

  # @gem-override マーカーの差分確認に使う開発ツール
  s.add_development_dependency 'gem_override_marker'
end
