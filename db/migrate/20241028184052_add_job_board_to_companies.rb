class AddJobBoardToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :job_board, :string
  end
end
