class ChangeValueCountry < ActiveRecord::Migration[8.0]
  def up
    japan = Spree::Country.find_by(name: "Japan")
    japan.update(name: "日本") if japan.present?
  end

  def down
    japan = Spree::Country.find_by(name: "日本")
    japan.update(name: "Japan") if japan.present?
  end
end
