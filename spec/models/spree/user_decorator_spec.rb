require 'spec_helper'

RSpec.describe Spree::UserDecorator do
  describe '#full_name' do
    subject { I18n.with_locale(:ja) { User.new(first_name: first_name, last_name: last_name).full_name } }

    context '姓名がある' do
      let(:first_name) { '花子' }
      let(:last_name) { '山田' }

      it { is_expected.to eq '山田 花子 様' }
    end

    # 法人・団体名を姓に入れた会員（ライリスト社の講師の取り込みなど）
    context '姓だけ' do
      let(:first_name) { nil }
      let(:last_name) { '株式会社ライリスト' }

      it { is_expected.to eq '株式会社ライリスト 様' }
    end

    context '姓名とも空' do
      let(:first_name) { nil }
      let(:last_name) { '' }

      it { is_expected.to be_nil }
    end
  end
end
