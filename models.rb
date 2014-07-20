require 'data_mapper'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'])

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String,  { :required => true }
  property :email, String, { :required => true,
                             :unique => true,
                             :format => :email_address }
  property :password, Text

  has n, :restaurants, { :child_key => [:creator_id] }
  # One user may create Many restaurants. I.e one `parent` (User) can have many
  # `children` (Restaurant). Datamapper is smart enough to infer from the symbol
  # `:restaurants` that we are referencing the `Restaurant` model
  #
  # The `Restaurant` references its `User` as `creator`. Each `Restaurant` stores
  # the `id` of the creator in a database column named `creator_id`. This is an
  # example of a `foreign key`; a column which references another table.
  #
  # The `child_key` option states that the `child` uses a foreign key column
  # named `creator_id` to reference the person who created it.
  #
  # If we used `belongs_to :user` down in the Restaurant model, we wouldn't need
  # this :child_key. However I find the semantics of `restaurant.creator` makes
  # it much more evident what the relationship between the user and restaurant
  # is.

  def password=(password)
    self.attribute_set(:password, BCrypt::Password.create(password))
  end

  def password
    BCrypt::Password.new(self.attribute_get(:password))
  end
end

class Restaurant
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :address, Text, { :required => true }

  belongs_to :creator, 'User'
  # Here we state there is a property called `creator` which references a `User`
  # model. This also ensures a `foreign key` `column` named `creator_id` exists
  # in the `restaurant` database table; which ties the user and the restaurant
  # together.
end

DataMapper.finalize
DataMapper.auto_upgrade!
