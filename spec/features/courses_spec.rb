require "rails_helper"

feature "course", type: :feature do
  background do
    @user = FactoryBot.create(:user)
    @course = FactoryBot.create(:course, user_id: @user.id)
  end

  scenario "ログイン前~courseの新規作成" do
    visit root_path
    click_link "ログイン"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "ログイン"
    expect(current_path).to eq users_path

    expect do
      click_link "クイズ作成"
      fill_in "course_name", with: "フィーチャースペックのテスト"
      click_button "次へ"
    end.to change(Course, :count).by(1)
  end

  scenario "ログイン前~courseの編集" do
    visit root_path
    click_link "ログイン"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "ログイン"
    expect(current_path).to eq users_path

    expect do
      click_link "詳細"
      expect(current_path).to eq new_course_question_path(course_id: @course.id)
      click_link "編集"
      expect(current_path).to eq edit_course_path(@course.id)
      fill_in "course_name", with: "編集テスト"
      click_button "次へ"
    end.to change { Course.find(@course.id).name }.from(@course.name).to("編集テスト")
  end

  scenario "ログイン前~courseの削除" do
    visit root_path
    click_link "ログイン"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "ログイン"
    expect(current_path).to eq users_path

    expect do
      click_link "詳細"
      expect(current_path).to eq new_course_question_path(course_id: @course.id)
      click_link "削除"
    end.to change(Course, :count).by(-1)
  end
end
