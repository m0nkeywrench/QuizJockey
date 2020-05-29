require 'rails_helper'

describe User do
  describe "#create" do
    it "正しいname, nickname, email, password, password_confirminationがあれば登録できること" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "nameが空の時は登録できないこと" do
      user = build(:user, name: "")
      user.valid?
      expect(user.errors[:name]).to include("を入力してください")
    end

    it "nameが英数字以外の文字を含んでいると登録できないこと" do
      user = build(:user, name: Faker::Alphanumeric.alphanumeric + "あ")
      user.valid?
      expect(user.errors[:name]).to include("は不正な値です")
    end

    it "nameがすでに存在するuserと重複していると登録できないこと" do
      user = create(:user)
      another_user = build(:user, name: user.name)
      another_user.valid?
      expect(another_user.errors[:name]).to include("はすでに存在します")
    end

    it "nicknameが空の時は登録できないこと" do
      user = build(:user, nickname: "")
      user.valid?
      expect(user.errors[:nickname]).to include("を入力してください")
    end

    it "emailが空の時は登録できないこと" do
      user = build(:user, email: "")
      user.valid?
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "emailがすでに存在しているuserと重複していると登録できないこと" do
      user = create(:user)
      another_user = build(:user, email: user.email)
      another_user.valid?
      expect(another_user.errors[:email]).to include("はすでに存在します")
    end

    it "passwordが空の時は登録できないこと" do
      user = build(:user, password: "", password_confirmation: "")
      user.valid?
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "passwordが7文字以下の時は登録できないこと" do
      user = build(:user, password: "qwertyu", password_confirmation: "qwertyu")
      user.valid?
      expect(user.errors[:password]).to include("は8文字以上で入力してください")
    end

    it "passwordが英数字以外の文字を含んでいると登録できないこと" do
      user = build(:user, password: "qwertyuあ", password_confirmation: "qwertyuあ")
      user.valid?
      expect(user.errors[:password]).to include("は不正な値です")
    end

    it "passwordとpassword_confirmationが一致しない場合には登録できないこと" do
      password = Faker::Alphanumeric.alphanumeric
      user = build(:user, password: password, password_confirmation: password + "a")
      user.valid?
      expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
    end
  end

  describe "#update" do
    before do
      @user = FactoryBot.create(:user)
    end

    it "正しくname, nickname, email, password, password_confirminationがあれば登録できること" do
      password = Faker::Internet.password(min_length: 8)
      user = @user.update(
        name: "a1", 
        nickname: "a", 
        email: Faker::Internet.free_email, 
        password: password,
        password_confirmation: password 
      )
      expect(user).to eq(true)
    end

    it "nameが空の時は更新できないこと" do
      user = @user.update(name: "")
      expect(user).to eq(false)
    end
    
    it "nameが英数字以外の文字を含んでいると更新できないこと" do
      user = @user.update(name: "a1あ")
      expect(user).to eq(false)
    end

    it "nameがすでに存在するuserと重複していると更新できないこと" do
      another_user = create(:user)
      user = @user.update(name: another_user.name)
      expect(user).to eq(false)
    end

    it "nicknameが空の時は更新できないこと" do
      user = @user.update(nickname: "")
      expect(user).to eq(false)
    end

    it "emailが空の時は更新できないこと" do
      user = @user.update(email: "")
      expect(user).to eq(false)
    end

    it "emailがすでに存在しているuserと重複していると更新できないこと" do
      another_user = create(:user)
      user = @user.update(email: another_user.email)
      expect(user).to eq(false)
    end

    it "passwordが空の時は更新できないこと" do
      user = @user.update(password: "", password_confirmation: "")
      expect(user).to eq(false)
    end

    it "passwordが7文字以下の時は更新できないこと" do
      user = @user.update(password: "qwertyu", password_confirmation: "qwertyu")
      expect(user).to eq(false)
    end

    it "passwordが英数字以外の文字を含んでいると更新できないこと" do
      user = @user.update(password: "qwertyuiお", password_confirmation: "qwertyuiお")
      expect(user).to eq(false)
    end

    it "passwordとpassword_confirmationが一致しない場合には更新できないこと" do
      user = @user.update(password: "qwertyui", password_confirmation: "qwertyuio")
      expect(user).to eq(false)
    end
  end
end