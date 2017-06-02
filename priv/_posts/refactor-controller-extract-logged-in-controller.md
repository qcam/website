{
  "title": "Refactor Controller - Extract LoggedIn-Controller",
  "slug": "refactor-controller-extract-logged-in-controller",
  "date": "2014-08-18",
  "keywords": ["ruby", "rails", "refactor"],
  "tags": ["ruby", "rails"],
  "description": "Sometimes your controllers actions require authentication and it makes your code look messy. This post is going to show you the idea of extracting them into LoggedInController"
}
---
Sometimes your controllers actions require authentication and it makes your code look messy. This post is going to show you the idea of extracting them into `LoggedInController`
---
Sometimes your controllers actions require authentication and it makes your code look messy. This post is going to show you the idea of extracting them into `LoggedInController`

### What is the idea?

I bet you have seen something like this

```ruby
class ProductsController < ApplicationController
  before_filter :authenticate_user!, except: :index

  protected
  def authenticate_user!
    redirect_to user_login_url, notice: 'Hey man! Log in first please!' unless user_logged_in?
  end
end
```

These lines of code are to filter users who are not logged in yet, redirect them and give them a nice alert.
But the problem here is to which the responsibility of user authentication should belong.
It is obviously not the job of `ProductsController`, as the products controller should not know the knowledge of how to filter an user.

### Just shift it to ApplicationController? - "No, please don't".

Why ApplicationController is not a good idea?

- ApplicationController should not know how to authenticate an user.
- Although we move `authenticate_user!` to ApplicationController, ProductsController should not know which actions should be filtered
  and how user is being redirected.

### Extract ProductsController bases on authentication context

My idea is to split ProductsController into two controllers: `LoggedIn::ProductsController` and `Public::ProductsController`

```ruby
class PublicController < ApplicationController; end

class LoggedInController < ApplicationController
  before_filter :authenticate_user!

  protected
  def authenticate_user!
    redirect_to user_login_url, notice: 'Hey man! Log in first please!' unless user_logged_in?
  end
end
```

And this is how your ProductsController looks like

```ruby
# app/controllers/public/products_controller.rb
class Public::ProductsController < PublicController
  def index
    # Your code here
  end
end

# app/controllers/logged_in/products_controller.rb
class LoggedIn::ProductsController < LoggedInController
  def new
    # Your code here
  end
end
```

### How to test it with RSpec

```ruby
# spec/controllers/logged_in_controller_spec.rb
require 'rails_helper'

describe LoggedInController do
  # stub an action to the controller
  controller(LoggedInController) do
    def index
      render nothing: true
    end
  end

  describe '#authenticate_user!' do
    let(:user) { create(:user) }

    before { @request.env['devise.mapping'] = Devise.mappings[:user] }

    def do_request
      get :index
    end

    context 'authenticated user' do
      before { sign_in user }
      before { do_request }

      it { is_expected.to_not redirect_to new_user_session_path }
    end

    context 'public user' do
      before { do_request }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end
end
```

