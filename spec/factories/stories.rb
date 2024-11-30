FactoryBot.define do
  factory :story do
    content { {
      author: "Test Author",
      title: "Test Title",
      paragraphs: ["Test paragraph 1", "Test paragraph 2"]
    } }

    trait :with_custom_content do
      content { {
        author: "Kavin",
        title: "The Great Michael Jordan",
        paragraphs: [
          "Michael Jordan was denied from JV.",
          "He cried, but he didn't give up.",
          "So he practiced."
        ]
      } }
    end
  end
end