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
end