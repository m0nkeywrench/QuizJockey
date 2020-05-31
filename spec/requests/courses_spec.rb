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
      expect(response.status).to eq 200
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

  describe "GET #new" do
    it "ログインしていないユーザーの場合リダイレクトが行われること" do
      get new_course_url
      expect(response.status).to eq 302
    end

    it "ログインしているユーザーの場合リクエストが成功すること" do
      user = FactoryBot.create(:user)
      sign_in user
      get new_course_url
      expect(response.status).to eq 200
    end
  end

  describe "GET #edit" do
    before do
      user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: user.id)
    end

    it "存在するcourse_urlへのリクエストに成功すること" do
      get courses_url
      expect(response.status).to eq 200
    end

    it "courseのname, descriptionが表示されていること" do
      get courses_url(@course.id)
      expect(response.body).to_not include(@course.name)
      expect(response.body).to_not include(@course.description)
    end

    context "courseが存在しない場合" do
      subject { -> { get course_url(@course.id + 1) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe "POST #create" do
    before do
      @user = FactoryBot.create(:user)
      sign_in @user
    end

    context "パラメータが妥当な場合" do
      it "リクエストが成功すること" do
        post courses_url, params: { course: FactoryBot.attributes_for(:course, user_id: @user.id) }
        expect(response.status).to eq 302
      end

      it "courseが登録されること" do
        expect do
          post courses_url, params: { course: FactoryBot.attributes_for(:course, user_id: @user.id) }
        end.to change(Course, :count).by(1)
      end

      it "new_course_questionにリダイレクトすること" do
        post courses_url, params: { course: FactoryBot.attributes_for(:course, user_id: @user.id) }
        expect(response).to redirect_to new_course_question_path(Course.last.id)
      end
    end

    context "パラメータが不正な場合" do
      it "リクエストが成功すること" do
        post courses_url, params: { course: FactoryBot.attributes_for(:course, name: nil) }
        expect(response.status).to eq 200
      end

      it "courseが登録されないこと" do
        expect do
          post courses_url, params: { course: FactoryBot.attributes_for(:course, name: nil) }
        end.to_not change(Course, :count)
      end

      it "エラー文言が表示されること" do
        post courses_url, params: { course: FactoryBot.attributes_for(:course, name: nil) }
        expect(response.body).to include("クイズの名前を入れてください")
      end
    end
  end

  describe "PUT #update" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      sign_in @user
    end

    context "パラメータが妥当な場合" do
      it "リクエストが成功すること" do
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        expect(response.status).to eq 302
      end

      it "nameが更新されること" do
        expect do
          put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        end.to change { Course.find(@course.id).name }.from("コースの名前").to("英単語テスト")
      end

      it "リダイレクトすること" do
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        expect(response).to redirect_to new_course_question_path(@course.id)
      end
    end

    context "パラメータが不正な場合" do
      it "リクエストが成功すること" do
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: nil) }
        expect(response.status).to eq 200
      end

      it "nameが変更されないこと" do
        expect do
          put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: nil) }
        end.to_not change(Course.find(@course.id), :name)
      end

      it "エラーが表示されること" do
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: nil) }
        expect(response.body).to include("クイズの名前を入れてください")
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      sign_in @user
    end

    it "リクエストが成功すること" do
      delete course_url(@course.id)
      expect(response.status).to eq 302
    end

    it "courseが削除されること" do
      expect do
        delete course_url(@course.id)
      end.to change(Course, :count).by(-1)
    end

    it "ユーザーマイページにリダイレクトすること" do
      delete course_url(@course.id)
      expect(response).to redirect_to user_path(@course.user.id)
    end
  end
end