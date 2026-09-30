require 'spec_helper'

RSpec.describe Spree::Address, type: :model do
  let(:japan) { create(:country, iso: 'JP', name: 'Japan') }
  let(:store) { create(:store, show_country_field: show_country_field, default_country: japan) }
  let(:address) do
    create(:address,
           firstname: '太郎',
           lastname: '山田',
           address1: '1-2-3',
           city: '渋谷区',
           zipcode: '150-0001',
           country: japan)
  end

  before do
    allow(Spree::Store).to receive(:current).and_return(store)
  end

  describe '#texts' do
    context 'show_country_fieldがfalseの場合' do
      let(:show_country_field) { false }

      it '国名が含まれないこと' do
        texts = address.texts
        expect(texts.join).not_to include('Japan')
      end
    end

    context 'show_country_fieldがtrueの場合' do
      let(:show_country_field) { true }

      it '国名が含まれること' do
        texts = address.texts
        expect(texts.join).to include('Japan')
      end
    end
  end

  describe 'カナの presence バリデーション (issue #1210 案A)' do
    let(:show_country_field) { false }
    let(:kana_store) { create(:store, use_kana_fields: true, default_country: japan) }

    let(:base_attrs) do
      { firstname: '太郎', lastname: '山田', address1: '1-2-3',
        city: '渋谷区', zipcode: '150-0001', country: japan }
    end

    before do
      allow(Spree::Store).to receive(:current).and_return(kana_store)
    end

    context 'use_kana_fields が false のストア' do
      before { allow(Spree::Store).to receive(:current).and_return(store) }

      it '新規でカナが空でも有効' do
        addr = Spree::Address.new(base_attrs)
        expect(addr).to be_valid
      end
    end

    context '新規レコード' do
      it 'カナが空だと無効(必須)' do
        addr = Spree::Address.new(base_attrs)
        expect(addr).not_to be_valid
        expect(addr.errors.attribute_names).to include(:lastname_kana, :firstname_kana)
      end

      it 'カナがあれば有効' do
        addr = Spree::Address.new(base_attrs.merge(lastname_kana: 'ヤマダ', firstname_kana: 'タロウ'))
        expect(addr).to be_valid
      end
    end

    context '永続済みでカナが空の既存住所(過去データ)' do
      let(:legacy) do
        addr = Spree::Address.new(base_attrs.merge(lastname_kana: nil, firstname_kana: nil))
        addr.save(validate: false)
        addr.reload
      end

      it '未変更ならスキップして有効(既存ユーザーがチェックアウトできる)' do
        expect(legacy).to be_valid
      end

      it 'カナ以外を編集してもスキップして有効' do
        legacy.city = '横浜市'
        expect(legacy).to be_valid
      end

      it 'カナを明示的にクリア(値あり→空)した場合は必須で無効' do
        addr = Spree::Address.new(base_attrs.merge(lastname_kana: 'ヤマダ', firstname_kana: 'タロウ'))
        addr.save(validate: false)
        addr.reload
        addr.lastname_kana = ''
        addr.firstname_kana = ''
        expect(addr).not_to be_valid
        expect(addr.errors.attribute_names).to include(:lastname_kana, :firstname_kana)
      end
    end

    context 'カナの format(カタカナのみ)' do
      it '入力があればカタカナ以外は無効' do
        addr = Spree::Address.new(base_attrs.merge(lastname_kana: 'yamada', firstname_kana: 'タロウ'))
        expect(addr).not_to be_valid
        expect(addr.errors.attribute_names).to include(:lastname_kana)
      end

      it 'カナ会社名に漢字が混じると、セイ・メイと同じ文言で無効' do
        addr = Spree::Address.new(base_attrs.merge(lastname_kana: 'ヤマダ', firstname_kana: 'タロウ', company_kana: '株式会社ヤマダショウジ'))
        expect(addr).not_to be_valid
        expect(addr.errors.full_messages_for(:company_kana)).to eq [ 'カナ会社名は全角カタカナで入力してください（漢字・ひらがな・数字・記号は使えません）' ]
      end
    end
  end
end
