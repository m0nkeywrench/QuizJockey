class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.string     :name,                          null: false
      t.text       :description
      t.boolean    :private,    default: false,    null: false
      t.references :user,       foreign_key: true, null: false

      t.timestamps
    end
  end
end
