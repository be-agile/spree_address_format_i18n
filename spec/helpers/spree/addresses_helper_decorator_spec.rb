require 'spec_helper'

RSpec.describe Spree::AddressesHelper, type: :helper do
  describe '#order_address_fields' do
    let(:store) { create(:store, show_country_field: show_country_field) }

    context 'show_country_fieldがfalseの場合' do
      let(:show_country_field) { false }

      it 'countryフィールドが含まれること（フォーム側でdisplay:noneで非表示にする）' do
        fields = helper.order_address_fields(store)
        expect(fields).to include('country')
      end
    end

    context 'show_country_fieldがtrueの場合' do
      let(:show_country_field) { true }

      it 'countryフィールドが含まれること' do
        fields = helper.order_address_fields(store)
        expect(fields).to include('country')
      end
    end
  end
end
