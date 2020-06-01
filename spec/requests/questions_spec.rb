require 'rails_helper'

describe QuestionsController, type: :request do
  describe "GET #index" do
    before do
      user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: user.id)
      @question = FactoryBot.create(:question, course_id: @course.id)
    end

    context "courseが存在する場合" do
      it "リクエストに成功すること" do
        get course_questions_url(course_id: @course.id)
        expect(response.status).to eq 200
      end

      it "courseのname, questionのsentence, answer, wrong1~3, commentaryがレスポンスに含まれること" do
        get course_questions_url(course_id: @course.id)
        expect(response.body).to include(@course.name)
        expect(response.body).to include(@question.sentence)
        expect(response.body).to include(@question.answer)
        expect(response.body).to include(@question.wrong1)
        expect(response.body).to include(@question.wrong2)
        expect(response.body).to include(@question.wrong3)
        expect(response.body).to include(@question.commentary)
      end
    end

    context "courseが存在しない場合" do
      subject { -> { get course_questions_url(course_id: @course.id + 1) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe "GET #new" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        get new_course_question_url(course_id: @course.id)
        expect(response.status).to eq 302
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        get new_course_question_url(course_id: @course.id)
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        get new_course_question_url(course_id: @course.id)
        expect(response.status).to eq 302
      end

      it "course_pathにリダイレクトすること" do
        sign_in @another_user
        get new_course_question_url(course_id: @course.id)
        expect(response).to redirect_to course_path(@course.id)
      end
    end

    context "作成者がリクエストした場合" do
      it "リクエストが成功すること" do
        get new_course_question_url(course_id: @course.id)
        expect(response.status).to eq 200
      end

      it "courseのname, descriptionが表示されていること" do
        get new_course_question_url(course_id: @course.id)
        expect(response.body).to include(@course.name)
        expect(response.body).to include(@course.description)
      end

      context "questionが0の場合" do
        it "ガイド文が表示されること" do
          get new_course_question_url(course_id: @course.id)
          expect(response.body).to include("作った4択はここに表示されます。")
        end
      end

      context "quesionがある場合" do
        it "questionのsentence, answer, wrong1~3がレスポンスに含まれること" do
          FactoryBot.create(:question, course_id: @course.id)
          get new_course_question_url(course_id: @course.id)
          expect(response.body).to include(@course.questions.first.sentence)
          expect(response.body).to include(@course.questions.first.answer)
          expect(response.body).to include(@course.questions.first.wrong1)
          expect(response.body).to include(@course.questions.first.wrong2)
          expect(response.body).to include(@course.questions.first.wrong3)
        end
      end
    end

    context "courseが存在しない場合" do
      subject { -> { get new_course_question_url(course_id: @course.id + 1) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
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

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response.status).to eq 302
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response.status).to eq 302
      end

      it "course_urlにリダイレクトすること" do
        sign_in @another_user
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response).to redirect_to course_url(@course.id)
      end
    end

    context "作成者がリクエストした場合" do
      it "リクエストが成功すること" do
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response.status).to eq 200
      end

      it "courseのname, descriptionが表示されていること" do
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response.body).to include(@course.name)
        expect(response.body).to include(@course.description)
      end

      it "questionのsentence, answer, wrong1~3がレスポンスに含まれること" do
        get edit_course_question_url(course_id: @course.id, id: @question.id)
        expect(response.body).to include(@course.questions.first.sentence)
        expect(response.body).to include(@course.questions.first.answer)
        expect(response.body).to include(@course.questions.first.wrong1)
        expect(response.body).to include(@course.questions.first.wrong2)
        expect(response.body).to include(@course.questions.first.wrong3)
        expect(response.body).to include(@course.questions.first.commentary)
      end
    end

    context "courseが存在しない場合" do
      subject { -> { get edit_course_question_url(course_id: @course.id + 1, id: @question.id) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end

    context "questionが存在しない場合" do
      subject { -> { get edit_course_question_url(course_id: @course.id, id: @question.id + 1) } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe "POST #create" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
        expect(response.status).to eq 302
      end

      it "questionが登録されないこと" do
        sign_out @user
        expect do
          post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
        end.to_not change(Question, :count)
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
        expect(response.status).to eq 302
      end

      it "questionが登録されないこと" do
        sign_in @another_user
        expect do
          post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
        end.to_not change(Question, :count)
      end

      it "course_urlにリダイレクトすること" do
        sign_in @another_user
        post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
        expect(response).to redirect_to course_url(@course.id)
      end
    end

    context "作成者がリクエストした場合" do
      context "パラメータが妥当な場合" do
        it "リクエストが成功すること" do
          post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
          expect(response.status).to eq 302
        end

        it "questionが登録されること" do
          expect do
            post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
          end.to change(Question, :count).by(1)
        end

        it "new_course_questionにリダイレクトすること" do
          post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question) }
          expect(response).to redirect_to new_course_question_path(@course.id)
        end
      end

      context "パラメータが不正な場合" do
        it "リクエストが成功すること" do
          post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question, answer: nil) }
          expect(response.status).to eq 200
        end

        it "questionが登録されないこと" do
          expect do
            post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question, answer: nil) }
          end.to change(Question, :count).by(0)
        end

        it "エラー文言が表示されること" do
          post course_questions_url(course_id: @course.id), params: { question: FactoryBot.attributes_for(:question, answer: nil) }
          expect(response.body).to include("必要な情報が足りません")
        end
      end
    end

    context "courseが存在しない場合" do
      subject { -> { post course_questions_url(course_id: @course.id + 1), params: { question: FactoryBot.attributes_for(:question) } } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe "PUT #update" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      @question = FactoryBot.create(:question, course_id: @course.id)
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
        expect(response.status).to eq 302
      end

      it "sentenseが変更されないこと" do
        sign_out @user
        expect do
          put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
        end.to_not change(Question.find(@question.id), :sentence)
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "作成者以外がリクエストした場合" do
      it "リダイレクトすること" do
        sign_in @another_user
        put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
        expect(response.status).to eq 302
      end
  
      it "sentenceが変更されないこと" do
        sign_in @another_user
        expect do
          put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
        end.to_not change(Question.find(@question.id), :sentence)
      end

      it "course_urlにリダイレクトすること" do
        sign_in @another_user
        put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
        expect(response).to redirect_to course_url(@course.id)
      end
    end

    context "作成者がリクエストした場合" do
      context "パラメータが妥当な場合" do
        it "リクエストが成功すること" do
          put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
          expect(response.status).to eq 302
        end

        it "sentenceが更新されること" do
          expect do
            put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
          end.to change { Question.find(@question.id).sentence }.from(@question.sentence).to("第1問")
        end

        it "new_course_questionにリダイレクトすること" do
          put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") }
          expect(response).to redirect_to new_course_question_path(@course.id)
        end
      end

      context "パラメータが不正な場合" do
        it "リクエストが成功すること" do
          put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: nil) }
          expect(response.status).to eq 200
        end

        it "sentenceが更新されること" do
          expect do
            put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: nil) }
          end.to_not change(Question.find(@question.id), :sentence)
        end

        it "エラー文言が表示されること" do
          put course_question_url(course_id: @course.id, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: nil) }
          expect(response.body).to include("必要な情報が足りません")
        end
      end
    end

    context "courseが存在しない場合" do
      subject { -> { put course_question_url(course_id: @course.id + 1, id: @question.id), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") } } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end

    context "questionが存在しない場合" do
      subject { -> { put course_question_url(course_id: @course.id, id: @question.id + 1), params: { question: FactoryBot.attributes_for(:question, sentence: "第1問") } } }
      it { is_expected.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end