class CreateOpenings < ActiveRecord::Migration[6.1]
  def change
    create_table :openings do |t|
      t.string :job_url, null: false
      t.string :location
      t.string :title
      t.string :company

      t.timestamps
    end
    add_index :openings, :job_url, unique: true
  end
end
