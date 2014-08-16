# ActiveForm

Set your models free from the `accepts_nested_attributes_for` helper. ActiveForm provides an object-oriented approach to represent our forms by building a Form Object rather than relying on ActiveRecord internals for doing this. The Form Object provides an API to describe the models involved in the form, their attributes and validations. The Form Object deals with create/update actions of nested objects in a more seamless way.

## Installation

Add this line to your Gemfile:


```ruby
gem 'active_form'
```

## Defining Forms

You want to manage conferences along with their speakers and their presentations. You start by defining a form to populate the root model, Conference.

```ruby
class ConferenceForm < ActiveForm::Base
  attributes :name, :city
  
  validates :name, :city, presence: true
end
```

To add fields to the form use the `::attributes` or `::attribute` method. The form can also define validation rules for the model it represents.

## The API

Forms have a ridiculously simple API with only a handful of public methods.

1. `#initialize` always requires a model that the form represents.
2. `#submit(params)` updates the form's fields with the input data (only the form, _not_ the model).
3. `#errors` returns validation messages in a classy ActiveModel style.
4. `#save` will call `#save` on the model and nested models. This method will validate the model and nested models and if no error arises then it will save them and return true.

In addition to the main API, forms expose accessors to the defined properties. This is used for rendering or manual operations.

## Setup

In your controller you'd create a form instance and pass in the models you want to work on.

```ruby
class ConferencesController
  def new
    @form = ConferenceForm.new(Conference.new)
  end
```

You can also setup the form for editing existing items.

```ruby
class ConferencesController
  def edit
    @form = ConferenceForm.new(Conference.find(1))
  end
```

ActiveForm will read property values from the model in setup. Given the following form class.

```ruby
class ConferenceForm < ActiveForm::Base
  attribute :name
```

Internally, this form will call `conference.name` to populate the title field.

## Rendering Forms

Your `@form` is now ready to be rendered, either do it yourself or use something like Rails' `#form_for`, `simple_form` or `formtastic`.

```haml
= form_for @form do |f|

  = f.input :name
  = f.input :city
```

Nested forms and collections can be easily rendered with `fields_for`, etc. Just use ActiveForm as if it would be an ActiveModel instance in the view layer.

## Syncing Back

After setting up your Form Object, you can populate the models with the submitted parameters.

```ruby
class ConferencesController
  def create
    @form = ConferenceForm.new(Conference.new)
    @form.submit(conference_params)
  end
```

This will write all the properties back to the model. In a nested form, this works recursively, of course.

## Saving Forms

After the forms have been populated with the posted data, you can save the model by calling #save.

```ruby
class ConferencesController
  def create
    @form = ConferenceForm.new(Conference.new)
    @form.submit(conference_params)

    respond_to do |format|
      if @form.save
        format.html { redirect_to @form, notice: "Conference: #{@form.name} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end
end
```

If the #save method returns false due to validation errors defined on the form, you can render again the form with the data that has been submitted and the errors found.

## Nesting Forms: 1-n Relations

ActiveForm also gives you nested collections.

Let's have Conferences with Speakers!

```ruby
class Conference < ActiveRecord::Base
  has_many :speakers
  validates :name, uniqueness: true
end
```

The form might look like this.

```ruby
class ConferenceForm < ActiveForm::Base
  attributes :name, :city, required: true

  association :speakers do
    attributes :name, :occupation, required: true
  end
end
```

This basically works like a nested `property` that iterates over a collection of speakers.

### has_many: Rendering

ActiveForm will expose the collection using the `#speakers` method.

```haml
= form_for @form |f|
  = f.text_field :name

  = f.fields_for :speakers do |s|
    = s.text_field :occupation
```

## Nesting Forms: 1-1 Relations

Speakers are allowed to have 1 Presentation.

```ruby
class Speaker < ActiveRecord::Base
  has_one :presentation
  belongs_to :conference
  validates :name, uniqueness: true
end
```

The full form should look like this:

```ruby
  class ConferenceForm < ActiveForm::Base
  attributes :name, :city, required: true

  association :speakers do
    attribute :name, :occupation, required: true

    association :presentation do
      attribute :topic, :duration, required: true
    end
  end
end
```

### has_one: Rendering

Use something like `#fields_for` in a Rails environment.

```haml
= form_for @form |f|
  = f.text_field :name
  = f.text_field :city

  = f.fields_for :presentation do |p|
    = p.text_field :topic
```
