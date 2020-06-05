require 'rails_helper'

describe Question do
  describe "#create" do
    before do
      @user = create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
    end

    it "sentence, answer, wrong1~3, commentary, course_idがあれば登録できる" do
      question = build(:question, course_id: @course.id)
      expect(question).to be_valid
    end

    it "course_idがない場合登録できないこと" do
      question = build(:question)
      question.valid?
      expect(question.errors[:course]).to include("を入力してください")
    end

    it "存在しないcourseのcourse_idがない場合登録できないこと" do
      question = build(:question, course_id: @course.id + 1)
      question.valid?
      expect(question.errors[:course]).to include("を入力してください")
    end

    it "sentenceがない場合登録できないこと" do
      question = build(:question, sentence: "", course_id: @course.id)
      question.valid?
      expect(question.errors[:sentence]).to include("を入力してください")
    end

    it "answerがない場合登録できないこと" do
      question = build(:question, answer: "", course_id: @course.id)
      question.valid?
      expect(question.errors[:answer]).to include("を入力してください")
    end

    it "wrong1がない場合登録できないこと" do
      question = build(:question, wrong1: "", course_id: @course.id)
      question.valid?
      expect(question.errors[:wrong1]).to include("を入力してください")
    end

    it "wrong2がない場合登録できないこと" do
      question = build(:question, wrong2: "", course_id: @course.id)
      question.valid?
      expect(question.errors[:wrong2]).to include("を入力してください")
    end

    it "wrong3がない場合登録できないこと" do
      question = build(:question, wrong3: "", course_id: @course.id)
      question.valid?
      expect(question.errors[:wrong3]).to include("を入力してください")
    end

    it "commentaryがない場合でも登録できること" do
      question = build(:question, commentary: "", course_id: @course.id)
      expect(question).to be_valid
    end
  end

  describe "#update" do
    before do
      @user = create(:user)
      @course = FactoryBot.create(:course, user_id: @user.id)
      @question = FactoryBot.create(:question, course_id: @course.id)
    end

    it "sentence, answer, wrong1~3, commentaryがあれば更新できる" do
      question = @question.update(
        sentence: Faker::Name.name,
        answer: Faker::Name.name,
        wrong1: Faker::Name.name,
        wrong2: Faker::Name.name,
        wrong3: Faker::Name.name,
        commentary: Faker::Name.name
      )
      expect(question).to eq(true)
    end

    it "course_idがない場合更新できないこと" do
      question = @question.update(course_id: "")
      expect(question).to eq(false)
    end

    it "存在しないcourseのcourse_idがない場合更新できないこと" do
      question = @question.update(course_id: @course.id + 1)
      expect(question).to eq(false)
    end

    it "sentenceがない場合更新できないこと" do
      question = @question.update(sentence: "")
      expect(question).to eq(false)
    end

    it "answerがない場合更新できないこと" do
      question = @question.update(answer: "")
      expect(question).to eq(false)
    end

    it "wrong1がない場合更新できないこと" do
      question = @question.update(wrong1: "")
      expect(question).to eq(false)
    end

    it "wrong2がない場合更新できないこと" do
      question = @question.update(wrong2: "")
      expect(question).to eq(false)
    end

    it "wrong3がない場合更新できないこと" do
      question = @question.update(wrong3: "")
      expect(question).to eq(false)
    end

    it "commentaryがない場合でも更新できること" do
      question = @question.update(commentary: "")
      expect(question).to eq(true)
    end
  end
end
