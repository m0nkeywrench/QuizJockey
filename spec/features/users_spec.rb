require "rails_helper"

feature "user", type: :feature do
  scenario "ユーザー新規登録" do
    visit root_path
    click_link "新規登録"
    expect(current_path).to eq new_user_registration_path

    expect do
      fill_in "user_name", with: "testname"
      fill_in "user_nickname", with: "ニックネーム"
      fill_in "user_email", with: "test@gmail.com"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"
      click_button "新規登録"
      expect(current_path).to eq users_path
    end.to change(User, :count).by(1)
  end
end
