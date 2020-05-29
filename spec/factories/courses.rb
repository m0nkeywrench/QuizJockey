FactoryBot.define do
  factory :course do
    name        {"コースの名前"}
    description {"どんなコースかを紹介する"}
    private     {Faker::Boolean.boolean}
  end
end