class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.integer :megami_code
      t.string :megami_name
      t.string :megami_fullname
      t.string :code
      t.string :name
      t.string :main_type
      t.string :sub_type
      t.string :kasa
      t.string :range
      t.string :damage_aura
      t.string :damage_life
      t.string :osame
      t.string :cost
      t.text :description
    end
  end
end
