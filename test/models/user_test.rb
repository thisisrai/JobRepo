require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(username: "testuser", password: "password", password_confirmation: "password", age: 25)
  end

  it "is valid with valid attributes" do
    expect(@user).to be_valid
  end

  it "is not valid without a username" do
    @user.username = nil
    expect(@user).to_not be_valid
  end

  it "is not valid with a duplicate username" do
    duplicate_user = @user.dup
    @user.save
    expect(duplicate_user).to_not be_valid
  end

  it "is not valid without a password" do
    @user.password = nil
    expect(@user).to_not be_valid
  end

  it "is not valid without a matching password confirmation" do
    @user.password_confirmation = "differentpassword"
    expect(@user).to_not be_valid
  end

  it "destroys associated jobs when the user is destroyed" do
    @user.save
    @user.jobs.create!(title: "Developer", application_url: "job.com", company: "Tech Co")
    expect { @user.destroy }.to change { Job.count }.by(-1)
  end
end