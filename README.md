# atomic-service
A base class to build DRY service objects in Ruby

## A service object:

```
class CreatePost < AtomicService
  attr_accessor :title, :body, :author
  attr_reader :post

  validates :title, :body, presence: true 
  validates_acceptance_of :posts_slots_available, if: :before_execution?

  def execute
    within_transaction do 
      create_post
    end
  end

  private 

  def create_post
    @post = Post.create(defined_attributes(:name, :post, :author))
    valid?(@post)
  end 

  def posts_slots_available
    author.posts.count <= 10
  end
end
```

## Executing a service object:

### Option 1: Instantiating and calling the service object
```
service = CreatePost.new(title: 'Foo', body: 'Bar', author, current_user)
if service.call
  flash[:notice] = 'Post created!'
else
  flash[:error] = "Error creating post: #{service.formatted_errors}"
end
```

### Option 2: Instantiating and calling the service object with a bang
```
service = CreatePost.new(title: 'Foo', body: 'Bar', author, current_user)
service.call! # An exception will be raised if the service does not execute correctly.
```

### Option 3: Calling directly via class method
```
data = CreatePost.call(title: 'Foo', body: 'Bar', author, current_user)

if !data.successful?
  puts data.formated_errors
end
```


