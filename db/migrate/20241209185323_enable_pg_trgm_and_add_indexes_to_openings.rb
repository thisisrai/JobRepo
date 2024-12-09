class EnablePgTrgmAndAddIndexesToOpenings < ActiveRecord::Migration[6.1]
  def change
    # Enable the pg_trgm extension
    enable_extension 'pg_trgm'

    # Add GIN indexes for fuzzy searching on location and title columns
    add_index :openings, :location, using: :gin, opclass: :gin_trgm_ops
    add_index :openings, :title, using: :gin, opclass: :gin_trgm_ops
  end
end
