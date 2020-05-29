require 'rails_helper'

describe Course do
  describe "#create" do
    before do
      @user = create(:user)
    end

    it "name, description, private, user_idが存在すれば登録できること" do
      course = build(:course, user_id: @user.id)
      expect(course).to be_valid
    end

    it "user_idが空の場合登録できないこと" do
      course = build(:course)
      course.valid?
      expect(course.errors[:user]).to include("を入力してください")
    end

    it "存在しないユーザーのuser_idだった場合登録できないこと" do
      course = build(:course, user_id: @user.id + 1)
      course.valid?
      expect(course.errors[:user]).to include("を入力してください")
    end

    it "nameが空の場合登録できないこと" do
      course = build(:course, name: "", user_id: @user.id)
      course.valid?
      expect(course.errors[:name]).to include("を入力してください")
    end

    it "descriptionが空でも登録できること" do
      course = build(:course, description: "", user_id: @user.id)
      expect(course).to be_valid
    end

    it "privateが空の場合登録できないこと" do
      course = build(:course, private: nil, user_id: @user.id)
      course.valid?
      expect(course.errors[:private]).to include("は一覧にありません")
    end
  end

  describe "#update" do
    before do
      @user = create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
    end

    it "name, description, private存在すれば更新できること" do
      course = @course.update(name: "aaa", description: "aaa", private: true)
      expect(course).to eq(true)
    end

    it "user_idが空の場合は更新できないこと" do
      course = @course.update(user_id: "")
      expect(course).to eq(false)
    end

    it "存在しないuserのuser_idの場合は更新できないこと" do
      course = @course.update(user_id: @user.id + 1)
      expect(course).to eq(false)
    end

    it "nameが空の場合更新できないこと" do
      course = @course.update(name: "")
      expect(course).to eq(false)
    end

    it "descriptionが空でも更新できること" do
      course = @course.update(description: "")
      expect(course).to eq(true)
    end

    it "privateが空の場合更新できないこと" do
      course = @course.update(private: nil)
      expect(course).to eq(false)
    end
  end

  describe "#get_course_list" do
    before do
      @user = FactoryBot.create(:user)
      @available_course = FactoryBot.create(:course, private: false, user_id: @user.id)
      FactoryBot.create(:question, course_id: @available_course.id)

      @private_course = FactoryBot.create(:course, private: true, user_id: @user.id)
      FactoryBot.create(:question, course_id: @private_course.id)

      @making_course = FactoryBot.create(:course, private:true, user_id: @user.id)
    end

    it "問題数0のcourseがカットされること" do
      expect(Course.get_course_list).to_not include(@making_course)
    end

    it "privateがtrueのコースがカットされること" do
      expect(Course.get_course_list).to_not include(@private_course)
    end

    it "問題数が0ではないかつprivateがfalseのコースがカットされないこと" do
      expect(Course.get_course_list).to include(@available_course)
    end
  end

  describe "#paginate" do
    before do # 作成時間降順で並ぶことを確かめるため、時間がかかる
      @user = FactoryBot.create(:user)
      @course_1st = FactoryBot.create(:course, user_id: @user.id)
      sleep 1
      @course_2nd = FactoryBot.create(:course, user_id: @user.id)
      sleep 1
      6.times do
        FactoryBot.create(:course, user_id: @user.id)
      end
      sleep 1
      @course_9th = FactoryBot.create(:course, user_id: @user.id)
    end

    it "9個courseがある場合、1ページ目には1番目に作成されたcourseは含まれない" do
      expect(Course.paginate(1)).to_not include(@course_1st)
    end

    it "9個courseがある場合、1ページ目には2番目に作成されたcourseは含まれる" do
      expect(Course.paginate(1)).to include(@course_2nd)
    end

    it "9個courseがある場合、1ページ目には9番目に作成されたcourseは含まれる" do
      expect(Course.paginate(1)).to include(@course_9th)
    end
  end

  describe "#search" do
    before do
      @user = FactoryBot.create(:user)
      @course = FactoryBot.create(:course, name: "英単語テスト", private: false, user_id: @user.id)
      @another_course = FactoryBot.create(:course, name: "フランス語単語テスト", private: false, user_id: @user.id)
      @making_course = FactoryBot.create(:course, name: "英単語テスト", private: true, user_id: @user.id)
    end

    it "nameに検索語句が含まれていて、privateがfalseのcourseが検索結果に含まれる" do
      expect(Course.search("英単語")).to include(@course)
    end

    it "nameに検索語句が含まれていても、privateがtrueだと検索結果に含まれない" do
      expect(Course.search("英単語")).to_not include(@another_course)
    end

    it "nameに検索語句が含まれないcourseは検索結果に含まれない" do
      expect(Course.search("英単語")).to_not include(@making_course)
    end
  end
end