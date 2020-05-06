class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.text       :sentence,  null: false
      t.string     :answer,    null: false
      t.string     :wrong1,    null: false
      t.string     :wrong2,    null: false
      t.string     :wrong3,    null: false
      t.text       :commentary
      t.references :course,    null: false, foreign_key: true

      t.timestamps
    end
  end
end
