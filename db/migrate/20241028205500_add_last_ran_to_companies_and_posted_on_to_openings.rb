class AddLastRanToCompaniesAndPostedOnToOpenings < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :last_ran, :date
    add_column :openings, :posted_on, :date
  end
end
