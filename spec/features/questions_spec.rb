require "rails_helper"

feature "question", type: :feature do
  background do
    @user = FactoryBot.create(:user)
    @course = FactoryBot.create(:course, user_id: @user.id)
    @question = FactoryBot.create(:question, course_id: @course.id)
  end

  scenario "ログイン前~question作成" do
    visit root_path
    click_link "ログイン"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "ログイン"
    click_link "詳細"
    expect(current_path).to eq new_course_question_path(course_id: @course.id)

    expect do
      fill_in "question_sentence", with: "テスト問題文"
      fill_in "question_answer", with: "テスト正答"
      fill_in "question_wrong1", with: "テスト誤答1"
      fill_in "question_wrong2", with: "テスト誤答2"
      fill_in "question_wrong3", with: "テスト誤答3"
      click_button "決定"
    end.to change(Question, :count).by(1)
  end

  scenario "ログイン前~question編集" do
    visit root_path
    click_link "ログイン"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "ログイン"
    click_link "詳細"
    page.all("a", class: "blue-link")[2].click
    expect(current_path).to eq edit_course_question_path(course_id: @course.id, id: @question.id)

    expect do
      fill_in "question_sentence", with: "変更後問題文"
      click_button "決定"
    end.to change { Question.find(@question.id).sentence }.from(@question.sentence).to("変更後問題文")
  end

  scenario "ログイン前~question削除" do
    visit root_path
    click_link "ログイン"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "ログイン"
    click_link "詳細"
    expect(current_path).to eq new_course_question_path(course_id: @course.id)

    expect do
      page.all("a", class: "blue-link")[3].click
    end.to change(Question, :count).by(-1)
  end
end
