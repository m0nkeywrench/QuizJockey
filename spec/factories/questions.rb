FactoryBot.define do
  factory :question do
    sentence   {Faker::Name.name}
    answer     {Faker::Name.name}
    wrong1     {Faker::Name.name}
    wrong2     {Faker::Name.name}
    wrong3     {Faker::Name.name}
    commentary {Faker::Name.name}
  end
end