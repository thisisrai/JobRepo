class CreateStories < ActiveRecord::Migration[6.1]
  def change
    create_table :stories do |t|
      t.jsonb :content, null: false, default: {}

      t.timestamps
    end
  end
end
