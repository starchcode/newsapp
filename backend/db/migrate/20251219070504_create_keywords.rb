class CreateKeywords < ActiveRecord::Migration[8.1]
  def change
    create_table :keywords do |t|
      t.references :user, null: false, foreign_key: true
      t.string :keyword

      t.timestamps
    end
  end
end
