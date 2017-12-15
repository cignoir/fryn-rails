class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.references :goddess, foreign_key: true
      t.string :no
      t.string :name
      t.string :main_type
      t.string :sub_type
      t.string :range
      t.string :damage_aura
      t.string :damage_life
      t.string :osame
      t.string :cost
      t.text :description

      t.timestamps
    end
  end
end
