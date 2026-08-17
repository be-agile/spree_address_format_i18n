require 'spec_helper'

RSpec.describe Spree::Store, type: :model do
  describe '#show_country_field' do
    let(:store) { create(:store) }

    context 'デフォルト値' do
      it 'falseであること' do
        expect(store.show_country_field).to be(false)
      end
    end

    context 'trueに設定した場合' do
      before { store.update(show_country_field: true) }

      it 'trueであること' do
        expect(store.show_country_field).to be(true)
      end
    end

    context 'falseに設定した場合' do
      before { store.update(show_country_field: false) }

      it 'falseであること' do
        expect(store.show_country_field).to be(false)
      end
    end
  end
end
