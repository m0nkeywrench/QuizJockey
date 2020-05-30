require 'rails_helper'

describe CoursesController, type: :request do
  describe "GET #index" do
    before do
      user1 = FactoryBot.create(:user)
      @course1 = FactoryBot.create(
        :course, 
        name: "英単語テスト", 
        description: "toeic必須英単語500", 
        private: false, 
        user_id: user1.id
      )
      FactoryBot.create(:question, course_id: @course1.id)

      user2 = FactoryBot.create(:user)
      @course2 = FactoryBot.create(
        :course, 
        name: "コンプライアンス研修", 
        description: "景品表示法について", 
        private: true, 
        user_id: user2.id
      )
      FactoryBot.create(:question, course_id: @course2.id)

      user3 = FactoryBot.create(:user)
      @course3 = FactoryBot.create(
        :course, 
        name: "作成中テスト", 
        description: "これから作る", 
        private: false, 
        user_id: user3.id
      )
    end

    it "リクエストが成功すること" do
      get courses_url
      expect(response.status).to eq(200)
    end

    it "questionありかつ、privateがfalseのcourseのname, description, user.nameが表示されていること" do
      get courses_url
      expect(response.body).to include(@course1.name)
      expect(response.body).to include(@course1.description)
      expect(response.body).to include(@course1.user.name)
    end

    it "privateがtrueのcourseのname, descriptionが表示されていないこと" do
      get courses_url
      expect(response.body).to_not include(@course2.name)
      expect(response.body).to_not include(@course2.description)
      expect(response.body).to_not include(@course2.user.name)
    end

    it "questionが0個のcourseのname, descriptionが表示されていないこと" do
      get courses_url
      expect(response.body).to_not include(@course3.name)
      expect(response.body).to_not include(@course3.description)
      expect(response.body).to_not include(@course3.user.name)
    end
  end

  describe "GET #show" do
    before do
      user = FactoryBot.create(:user)
      @course1 = FactoryBot.create(:course, user_id: user.id)
      @course2 = FactoryBot.create(:course, user_id: user.id)
      FactoryBot.create(:question, course_id: @course1.id)
    end

    it "questionがあるcourseへのリクエストが成功すること" do
      get course_url(@course1.id)
      expect(response.status).to eq 200
    end

    it "courseのname, description, user.name, questionの数が表示されていること" do
      get course_url(@course1.id)
      expect(response.body).to include(@course1.name)
      expect(response.body).to include(@course1.description)
      expect(response.body).to include(@course1.user.name)
      expect(response.body).to include("全#{@course1.questions.length}問")
    end

    it "questionが0のcourseに遷移する時リダイレクトが行われること" do
      get course_url(@course2.id)
      expect(response.status).to eq 302
    end

    context "courseが存在しない場合" do
      subject { -> { get course_url(@course2.id + 1) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end