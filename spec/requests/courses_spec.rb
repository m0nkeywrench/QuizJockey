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

    context "questionありかつ、privateがfalseのcourseの場合" do
      it "name, description, user.nameが表示されていること" do
        get courses_url
        expect(response.body).to include(@course1.name)
        expect(response.body).to include(@course1.description)
        expect(response.body).to include(@course1.user.name)
      end
    end

    context "questionありかつ、privateがtrueのcourseの場合" do
      it "name, description, user_nameが表示されていないこと" do
        get courses_url
        expect(response.body).to_not include(@course2.name)
        expect(response.body).to_not include(@course2.description)
        expect(response.body).to_not include(@course2.user.name)
      end
    end

    context "questionが0個かつ、privateがfalseのcourseの場合" do
      it "name, description, user_nameが表示されていないこと" do
        get courses_url
        expect(response.body).to_not include(@course3.name)
        expect(response.body).to_not include(@course3.description)
        expect(response.body).to_not include(@course3.user.name)
      end
    end
  end

  describe "GET #show" do
    before do
      user = FactoryBot.create(:user)
      @course1 = FactoryBot.create(:course, user_id: user.id)
      @course2 = FactoryBot.create(:course, user_id: user.id)
      FactoryBot.create(:question, course_id: @course1.id)
    end

    context "questionが存在するcourseの場合" do
      it "リクエストが成功すること" do
        get course_url(@course1.id)
        expect(response.status).to eq 200
      end

      it "name, description, user.name, questionの数が表示されていること" do
        get course_url(@course1.id)
        expect(response.body).to include(@course1.name)
        expect(response.body).to include(@course1.description)
        expect(response.body).to include(@course1.user.name)
        expect(response.body).to include("全#{@course1.questions.length}問")
      end
    end

    context "questionが0のcourseだった場合" do
      it "リダイレクトが行われること" do
        get course_url(@course2.id)
        expect(response.status).to eq 302
      end

      it "root_pathにリダイレクトすること" do
        get course_url(@course2.id)
        expect(response.status).to redirect_to root_url
      end
    end

    context "courseが存在しない場合" do
      subject { -> { get course_url(@course2.id + 1) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe "GET #new" do
    context "ログインしていない場合" do
      it "リダイレクトが行われること" do
        get new_course_url
        expect(response.status).to eq 302
      end

      it "new_user_session_pathにリダイレクトすること" do
        get new_course_url
        expect(response.status).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      it "リクエストが成功すること" do
        user = FactoryBot.create(:user)
        sign_in user
        get new_course_url
        expect(response.status).to eq 200
      end
    end
  end

  describe "GET #edit" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      @question = FactoryBot.create(:question, course_id: @course.id)
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "course作成者がリクエストした場合" do
      it "リクエストに成功すること" do
        get edit_course_url(@course.id)
        expect(response.status).to eq 200
      end

      it "name, descriptionが表示されていること" do
        get edit_course_url(@course.id)
        expect(response.body).to include(@course.name)
        expect(response.body).to include(@course.description)
      end
    end

    context "course作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        get edit_course_url(@course.id)
        expect(response.status).to eq 302
      end

      it "course_urlにリダイレクトすること" do
        sign_in @another_user
        get edit_course_url(@course.id)
        expect(response).to redirect_to course_url(@course.id)
      end
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        get edit_course_url(@course.id)
        expect(response.status).to eq 302
      end

      it "new_user_session_pathにリダイレクトすること" do
        sign_out @user
        get edit_course_url(@course.id)
        expect(response).to redirect_to new_user_session_path
      end
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

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        post courses_url, params: { course: FactoryBot.attributes_for(:course, user_id: @user.id) }
        expect(response.status).to eq 302
      end

      it "courseが登録されないこと" do
        sign_out @user
        expect do
          post courses_url, params: { course: FactoryBot.attributes_for(:course, user_id: @user.id) }
        end.to_not change(Course, :count)
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        post courses_url, params: { course: FactoryBot.attributes_for(:course, user_id: @user.id) }
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "ログインしている場合" do
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
  end

  describe "PUT #update" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      FactoryBot.create(:question, course_id: @course.id)
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        expect(response.status).to eq 302
      end

      it "nameが変更されないこと" do
        sign_out @user
        expect do
          put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        end.to_not change(Course.find(@course.id), :name)
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "course作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        expect(response.status).to eq 302
      end

      it "nameが変更されないこと" do
        sign_in @another_user
        expect do
          put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        end.to_not change(Course.find(@course.id), :name)
      end

      it "course_urlにリダイレクトすること" do
        sign_in @another_user
        put course_url(@course.id), params: { course: FactoryBot.attributes_for(:course, name: "英単語テスト") }
        expect(response).to redirect_to course_url(@course.id)
      end
    end

    context "course作成者がリクエストした場合" do
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

        it "new_course_question_pathにリダイレクトすること" do
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
  end

  describe "DELETE #destroy" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      3.times { FactoryBot.create(:question, course_id: @course.id) }
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        delete course_url(@course.id)
        expect(response.status).to eq 302
      end

      it "courseが削除されないこと" do
        sign_out @user
        expect do
          delete course_url(@course.id)
        end.to change(Course, :count).by(0)
      end

      it "紐づいているquestionも削除されないこと" do
        sign_out @user
        expect do
          delete course_url(@course.id)
        end.to change(Question, :count).by(0)
      end

      it "new_user_sessionにリダイレクトすること" do
        sign_out @user
        delete course_url(@course.id)
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        delete course_url(@course.id)
        expect(response.status).to eq 302
      end

      it "courseが削除されないこと" do
        sign_in @another_user
        expect do
          delete course_url(@course.id)
        end.to change(Course, :count).by(0)
      end

      it "紐づいているquestionも削除されないこと" do
        sign_in @another_user
        expect do
          delete course_url(@course.id)
        end.to change(Question, :count).by(0)
      end

      it "course_urlにリダイレクトすること" do
        sign_in @another_user
        delete course_url(@course.id)
        expect(response).to redirect_to course_url(@course.id)
      end
    end

    context "作成者がリクエストした場合" do
      it "リクエストが成功すること" do
        delete course_url(@course.id)
        expect(response.status).to eq 302
      end

      it "courseが削除されること" do
        expect do
          delete course_url(@course.id)
        end.to change(Course, :count).by(-1)
      end

      it "紐づいているquestionも削除されること" do
        expect do
          delete course_url(@course.id)
        end.to change(Question, :count).by(-3)
      end

      it "ユーザーマイページにリダイレクトすること" do
        delete course_url(@course.id)
        expect(response).to redirect_to users_url
      end
    end
  end
end
