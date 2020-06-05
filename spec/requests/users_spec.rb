require 'rails_helper'

describe UsersController, type: :request do
  describe "GET #index" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        get users_url
        expect(response.status).to eq 302
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        get users_url
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "ログインしている場合" do
      it "リクエストに成功すること" do
        get users_url
        expect(response.status).to eq 200
      end

      it "courseのname, questionの数がレスポンスに含まれること" do
        get users_url
        expect(response.body).to include(@course.name)
        expect(response.body).to include(@course.questions.length.to_s)
      end
    end
  end

  describe "GET #profile_edit" do
    before do
      @user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        get profile_edit_user_url(@user.id)
        expect(response.status).to eq 302
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        get profile_edit_user_url(@user.id)
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "ログインしている場合" do
      it "リクエストに成功すること" do
        get profile_edit_user_url(@user.id)
        expect(response.status).to eq 200
      end

      it "userのname, nicknameがレスポンスに含まれること" do
        get profile_edit_user_url(@user.id)
        expect(response.body).to include(@user.name)
        expect(response.body).to include(@user.nickname)
      end
    end

    context "userが存在しない場合" do
      it "リクエストに成功すること" do
        get profile_edit_user_url(@user.id + 1)
        expect(response.status).to eq 200
      end

      it "urlのidに依存せずに、ログイン中のuserのname, nicknameがレスポンスに含まれること" do
        get profile_edit_user_url(@user.id + 1)
        expect(response.body).to include(@user.name)
        expect(response.body).to include(@user.nickname)
      end
    end
  end

  describe "PATCH #update_profile" do
    before do
      @user = FactoryBot.create(:user)
      @another_user = FactoryBot.create(:user)
      sign_in @user
    end

    context "ログインしていない場合" do
      it "リダイレクトすること" do
        sign_out @user
        patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
        expect(response.status).to eq 302
      end

      it "userのnameが変更されないこと" do
        sign_out @user
        expect do
          patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
        end.to_not change(User.find(@user.id), :name)
      end

      it "userのnicknameが変更されないこと" do
        sign_out @user
        expect do
          patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
        end.to_not change(User.find(@user.id), :nickname)
      end

      it "new_user_session_urlにリダイレクトすること" do
        sign_out @user
        patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "ログインしている場合" do
      context "パラメータが妥当な場合" do
        it "リダイレクトすること" do
          patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
          expect(response.status).to eq 302
        end

        it "userのnameが変更されること" do
          expect do
            patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
          end.to change { User.find(@user.id).name }.from(@user.name).to("change")
        end

        it "userのnicknameが変更されること" do
          expect do
            patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
          end.to change { User.find(@user.id).nickname }.from(@user.nickname).to("変更後")
        end

        it "user_urlにリダイレクトすること" do
          patch profile_update_user_url(@user.id), params: { user: { name: "change", nickname: "変更後" } }
          expect(response).to redirect_to users_url
        end
      end

      context "パラメータが不正な場合" do
        it "リクエストに成功すること" do
          patch profile_update_user_url(@user.id), params: { user: { name: @another_user.name, nickname: "変更後" } }
          expect(response.status).to eq 200
        end

        it "userのnameが変更されないこと" do
          expect do
            patch profile_update_user_url(@user.id), params: { user: { name: @another_user.name, nickname: "変更後" } }
          end.to_not change(User.find(@user.id), :name)
        end

        it "userのnicknameが変更されないこと" do
          expect do
            patch profile_update_user_url(@user.id), params: { user: { name: @another_user.name, nickname: "変更後" } }
          end.to_not change(User.find(@user.id), :nickname)
        end

        it "エラー文言が表示されること" do
          patch profile_update_user_url(@user.id), params: { user: { name: @another_user.name, nickname: "変更後" } }
          expect(response.body).to include("ユーザー名はすでに存在します")
        end
      end

      context "ログイン中のuserのidとparamsのidの値が異なる場合" do
        it "リダイレクトすること" do
          patch profile_update_user_url(@user.id + 1), params: { user: { name: "change", nickname: "変更後" } }
          expect(response.status).to eq 302
        end

        it "userのnameが変更されること" do
          expect do
            patch profile_update_user_url(@user.id + 1), params: { user: { name: "change", nickname: "変更後" } }
          end.to change { User.find(@user.id).name }.from(@user.name).to("change")
        end

        it "userのnicknameが変更されること" do
          expect do
            patch profile_update_user_url(@user.id + 1), params: { user: { name: "change", nickname: "変更後" } }
          end.to change { User.find(@user.id).nickname }.from(@user.nickname).to("変更後")
        end

        it "user_urlにリダイレクトすること" do
          patch profile_update_user_url(@user.id + 1), params: { user: { name: "change", nickname: "変更後" } }
          expect(response).to redirect_to users_url
        end
      end
    end
  end
end
