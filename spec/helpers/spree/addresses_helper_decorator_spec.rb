require 'spec_helper'

RSpec.describe Spree::AddressesHelper, type: :helper do
  describe '#address_field' do
    let(:address) { Spree::Address.new }
    let(:form) { ActionView::Helpers::FormBuilder.new(:address, address, helper, {}) }

    subject { helper.address_field(form, method) }

    context '入力例が定義された欄' do
      let(:method) { :company_kana }

      it { is_expected.to include 'placeholder="例）カブシキガイシャヤマダショウジ"' }
    end

    context '入力例が定義されていない欄' do
      let(:method) { :country }

      it { is_expected.to include 'placeholder="国"' }
    end

    context 'エラーがある欄' do
      let(:method) { :company_kana }

      before { address.errors.add(:company_kana, :invalid_katakana) }

      it { is_expected.to include '<p class="text-red-500 text-xs mt-1">カナ会社名は全角カタカナで入力してください（漢字・ひらがな・数字・記号は使えません）</p>' }
    end

    context 'エラーがない欄' do
      let(:method) { :company_kana }

      it { is_expected.not_to include 'text-red-500' }
    end

    context 'ブロック付き(zipcode など中身を呼び出し側が組み立てる欄)' do
      let(:method) { :zipcode }

      subject { helper.address_field(form, method) { 'ZIP' } }

      before { address.errors.add(:zipcode, :invalid) }

      it { is_expected.to include 'ZIP' }
      it { is_expected.to include '<p class="text-red-500 text-xs mt-1">郵便番号は不正な値です</p>' }
    end
  end

  describe '#address_zipcode' do
    let(:address) { Spree::Address.new }
    let(:form) { ActionView::Helpers::FormBuilder.new(:address, address, helper, {}) }

    subject { helper.address_zipcode(form, nil) }

    it { is_expected.to include 'placeholder="例）150-0001"' }
  end

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
