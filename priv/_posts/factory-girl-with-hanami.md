{
  "title": "Using Factory Girl with Hanami model",
  "slug": "factory-girl-with-hanami",
  "date": "2016-04-12",
  "description": "Factory Girl has been widely adopted for testing data production by the Rails community, but how to use it with Hanami Model?",
  "keywords": ["hanami model", "factory girl", "testing"],
  "tags": ["testing", "ruby"]
}
---
Hanami is one of the most popular and trending Ruby frameworks today, well-known for its clean architecture and testability. In this post we are going to explore how we can use Hanami Model with Factory for fast testing data generation.
---
Hanami is one of the most popular and trending Ruby frameworks today, well-known for its clean architecture and testability. In this post we are going to explore how we can use Hanami Model with Factory for fast testing data generation.

# Data Persistence in Hanami

Model is one of the best features of Hanami, with the separation of Entity and Repository, following the architecture of Domain Driven Design. Entity holds the domain logic, whilst Repository is responsible for persistence.

Here is the code example to persist data with Hanami Model.

```rb
class Book
  include Hanami::Entity
  attribute :title, :author
end

class BookRepository
  include Hanami::Repository
end

# And to persist
book = Book.new(title: 'Ruby Under a Microscope', author: 'Pat Shaughnessy'))
BookRepository.create(book)
```

# Using Factory Girl for test data production

Factory Girl has been widely adopted for testing data production by the Ruby on Rails community, but it could be used in PORO way. So let's see how we can integrate Factory Girl in our Hanami application for testing.

Generally here is how you generate data with Factory Girl in RSpec.

```rb
FactoryGirl.define do
  factory :book do
    title 'The sample book'
    author 'John Cena'
  end
end

describe Book do
  it 'does something' do
    book = create(:book)
  end
end
```

By default, Factory Girl will call the `#save!` method of the instance. But in Hanami we use Repository to persist data, as mentioned above.

But Factory Girl already got you covered.

```rb
FactoryGirl.define do
  factory :book do
    title 'The sample book'
    author 'John Cena'

    # Add your custom method here to persist object
    to_create { |instance| BookRepository.create(instance) }
  end
end
```

That's it! Enjoy coding!

