class CreatePrivacyTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :privacy_tokens do |t|
      t.string :signature

      t.timestamps null: false
    end
  end
end
