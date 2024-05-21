class CreateJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :jobs do |t|
      t.string :outcome
      t.datetime :date_applied
      t.string :company
      t.string :title
      t.string :application_url
      t.string :resume_title
      t.string :interview
      t.date :interview_date
      t.time :time

      t.timestamps
    end
  end
end
