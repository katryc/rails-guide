#Questions
#______________________________________________________________________________

#                       Getting Started Guide

#----------------          

#Q:What line of code do you need to change the Rails Welcome Aboard page? In what file do we put this code?

#A: You can change the "root" of your routes to the page you would want to be your landing(home) page like this:

config/routes.rb/:
   
   root "welcome#index"


#Q: What paths are generated by the following code: resources :articles ?

#A: Resources are collections of simular objects that belong to your model; depending on what name you give your model, the name of our resources will change accordingly. You can specify the resources in the config/routes.rb file, in order to create paths to your objects. To see what paths were generated, run 'rake routes' in your terminal. You will see a that yuor "resources" will have all the standard RESTful actions generated for free by rails in the "verb" colomn". In order to use proper links, just pick the path from the "prefix" colomn" to use for your specific links and buttons. 
# in case of resources :article example, we will probably be getting the following paths:

  article
  new_article
  edit_article
  update_article
  destroy_article
  

  


  #------------------

#Q:  What line of code do you need to fix the following error: ActiveModel::ForbiddenAttributesError ? Which file? Why?

#A: This error is the result of violating the Strong Parameters rules. It is the rule of controlling the access to the data: security, if you will. In your Articles Controller you have private method at the very bottom where you specify the parameters that are open(permit(:args, :args)) to modification, so if you are trying to manipulate the parameters that are not included in the declaration of your private 'article_params' method, you will get a conflict in your ActiveModel.
#To fix the error, make sure to include this(put whatever argments you want to be accessable!):

app/controllers/articles_controller.rb
   
private

def article_params
    params.require(:particle).permit(:title, :text)
  
  end
  
  




  #-----------------------
#Q: Provide one example of a refactoring techinque using partials. Include the partial file name, the code inside the partial, and the code used to display that partial.

#A: Partials are partial templates. Partials are extremely useful for managing chunks of code acroos the views. You can easily move the code you want to render to any of your view controllers in chunks. Most common example is renedring the 'form_for' integration: 

app/views/articles/_form.html.erb
#NB: partials are by convention named ' _name'


<%= form_for @article do |f|%>
<%= f.collection_select :category_id, Category.all, :id, :name, { prompt: "Add a corresponding category"}%>

<h2>Title  <%= f.text_field :title%>
  <br>
<h2>Content <%= f.text_area :content%>
  <br>
  <%= f.submit%>
  <%end>
 
 
# This form containes fields for chosing the categorydispaying the :title, :content and a submit button
#  Now we don't want to get our code wet and keet inserting the same lines of code every time we want to display the same fields on our pages--that's where the partial comes handy: we can just use renderind in the view controller of our choice like this, for example:

app/views/articles/edit.html.erb

<h1>Edit this articles</h1>
<%= render 'form'%>
<%end>

# here we simply calling "render" to create a response that will be send to the browser even though we didnt write it in the edit.html.erb. That is the magic of Controller ability of sending the response by wraping the view in layouts or possible partial views, that we take advantage of.


#_____________________________________________________________________________
#
#                                    Models
#
#                             Active Record Basics
#-----------------------------------------------------------------------------
#
# Questions:
#
# Q: What kind of abilities does Active Record grant us? What does it simplify?

# A: ActiveRecord is an interface that Rails creates between the DB and the APP, also known as Object-Relashional-Mapping(ORP). It takes the data from inside of the DB by writing Query statemnts(SQL for example)and manipulate it as if it were just another Object in Ruby. So instead of writing some specific code to get into the DB, we can use ActiveRecord as a straight channel to retrieve whatever we want by using a inbuild AR methods. 
# e.g:

Article.all
Article.find()
Article.find().destroy
Article.create()

#Active Record also doesn't care what type of DB you are using, so it simplifies the whole Application-DB interraction

#-------------------------

#
# Q: Give me an example of a naming convention in Rails. How does Rails use this to make the development problem easier? How would you override this?


# A: "Convention over Configuation" is Rails' moto. It is very much applicable to naming conventions as well. By default Rails is using the same conventions as Ruby. The additions are: Controllers uses pluralization; Model is always singular; Tables in DB all plural lowercase with underscore; Migrations: Uppercase/mixed; Files: lowercase and underscore; Shared files and Partials: start with underscore; Primary_Key: assumed to be named 'id'; Foreign_Key: singular name of the table with "_id" added to it;
#The best part about it is that most of the time Rails will do the naming for you automatically when generating Controllers and Models.
#You can override the default table name that rails expects as follows
#
# Following code specifies the Article class should use the article_items table:

app/models/article.rb

class Article < ActiveRecord::Base
set_table_name ‘article_items’
end

#if we don’t want to give plural names to database tables. we can configure rails to work with singular named tables by adding as follows to: 
 config/environment.rb
 
 ActiveRecord::Base.pluralize_table_names = false


#--------------------------
# Q:  What is a validation? How do you use one and why is it important?

#A: Validation is a process of setting criteria for the data in order for it to be included in your database. If the data is not meeting the criteria, it will not be saved in your DB. There are different ways of implimenting it(in controllers, using JS etc.), but the best way is to use Model-level validation: 
app/models/user.rb

class User < ActiveRecord::Base
  validates :email, presence: true
  validates :name, length: {minimum: 5}
  validates :password, length: {in 8..12}
  
end  

#Here, if we try to save a new_user with an email, name not shorter than 5 chars and a password in the range of 8 and 12 chars we will succeed. Active Record will see that the object corresponds to all the rows in DB and will create a new record. If we try to save an object that doesn't, the validation will fail, SQL Insert operation will not be send and the object will not be saved as a new record.
#Validation, hence, is something you can play around with, running different filters for creating, saving and updating objects.  
#For obvius security reasons and in order just to keep your DB clean and well-organized, this is a very important part of APP development.
#-----------------------------------------------------------------------------------------
#                                    Active Record Associations
#
# Questions
#
# Q:  What are a few examples of the type of associations you can declare in Rails? Explain why you would use one of these associations. Include specific examples of what the code would look like.
#
# A: When creating multiple Models, you would most probablt want to use Association to provide the relashionship based controllers for your application. The most common associations are "has_many" and "belongs_to", which on the database level will mean that every row in Model B has a column "modelA_id" that it belongs_to and Model A has_many models B.  
# e.g:
class Article < ActiveRecord::Base
  has_many :posts
end
#and

class Post < ActiveRecord::Base
  belongs_to :article #notice!U must use singular form here; conventions!
end  
#Now we need to add a an idex to establish a connection or reference:
terminal:
rails g migration AddArticleIdToPost article_id:integer
#This will generate the column with an idex to reference to the Article: Article can have many posts, but all posts will always belong to the Article at a corresponding id.
#now we can write something like this in our Controller:
def create
@post = Post.create params(title: "love", article_id: article_id)



#Apart from these we also can establish between two Models indirectly through a third one:

class Article < ActiveRecord::Base
  has_many :posts, :through :users
end
   
    
#------------------------------------------------------------------------
  
#
# Q: What are two ways of declaring many to many relationships? Why would you use one over another?
# A: There are two ways to create a many-to-many relationship. 
# You can use the :has_and_belongs_to_many or the :has_many :through methods. The choice to choose one over the other has to do if the join table has a model class attached do it or not. 

class Article < ActiveRecord::Base
  has_and_belongs_to_many :posts
end
#The conventions would mean the Article’s primary key would be stored as a foreign key (article_id) in a join table (post_article) which would contain the article_id of the ‘many’ part relationship’. No other intermediate model is involved.
#or with another User model that Post has an association with;through: Specifies an association through which to perform the query. This can be any other type of association, including other :through associations.
class Article < ActiveRecord::Base
  has_many :posts, :through :users
end

#__________________________
#
# Q: How do you make sure that when you delete an object, all of its dependents will be destroyed as well? For example: Assuming the correct association, if we delete a Customer, we want to make sure his orders are delted.
# A: Use associations! If you specify the "dependent" action in your model, it will also be applied to the referenced Objects.
#e.g:
 
class Article < ActiveRecord::Base
  has_many :posts, dependent: :destroy
end
#so now when we destroy an article, all the posts associated with it will be destroyed as well.
#__________________________
# Q:  Let's say we have orders belonging to customers. Our Customer can either be 'active' or 'inactive'. 
#     What option can we pass our association so that we only pull the active customers?
#     Bonus: Why would you want to use a technique like this?

class User < ActiveRecord::Base
  attr_accessible :active
  has_many :accounts
end
# We would want to keep the access to the data open to specific users that are active.




#------------------------------------------------------------------------------------------

#                                              Views
#
#                                       Action View Overview
#-------------------------------------------------------------------------------------------
#
# Questions
#
# Q: Give an example of a 'template', and a 'layout'. Provide the file path as well as the respective code inside the file.
#Layout is the Application generic view that belongs throughout:
  layouts/posts/posts_view.htm.erb
   
  <html>
  <head>
    <title>Posts</title>
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
    <%= csrf_meta_tags %>
  </head>
  <body>
  <div>
          <%= yield %>
     
  </div>

  <%= render 'shared/footer'%>
  </body>
  </html>
  #template is more of a separate view container that needs to be filled in:
  app/views/show.html.erb
  
  <%=image_tag(@post.image.url(:medium))%>
  <hr>
  <%=@post.description%>
  <hr>
  <%=@post.cat_id%>
  <%=link_to "All images", posts_path%>

#---------------------------------
# Q: What is a 'partial' and why would you use one? Provide an example file path and file name. Give an example of how you would call it within a template.
# A:  See "Refactoring techniques using Partials"


#----------------------------------
# Q: What are the two types of form helpers and how do they differ?

# A: Mainly there are view_helpers with a "name_tag"(text_field_tag, label_tag, radio_button_tag etc) and "non_tag"(color_field, week_field). The "tag" helpers require correct parameter name, while the latter, are not that strict. For these helpers the first argument is the name of an instance variable and the second is the name of a method (usually an attribute) to call on that object. 
#e.g:

<%= text_field(:title, :content)>

#vs.

<%=text_field_tag(:title, :content)>
#_______________________________________________________________________________________
#
#
#                                  Controllers
#
#                          Action Controller Overview
#______________________________________________________________________________________
#
# Questions
#
# Q: What is a controller? What is an action? How are they related? How are they used in a Rails app?
# A: In the MVC model, C stands for Controllers. They are responsible for connecting the Model with the view. 
#    They create routes and make sure that the view display appropriate data passed from the Models.
#    Actions are basically methods that are called on Controller class.
#    By default when generating a Rails App we get all the CRUD actions for free: create, read, update, delete. 
#___________________________________
#
# Q: What two keys will always be included in the params hash?
# A: Params hash can contain array and nested hashes, 
#___________________________________
#
# Q: How can you store cookies on the client? Provide example code.
# A: 
#___________________________________
#
# Q: Give an example of some code you might want to include in your Application Controller.
# A: The ApplicationController contains code that can be run in all your controllers and it inherits 
#   from Rails ActionController::Base class, so you would want to put some handy methods and filters in here.
#   It can also be a kind of refactoring: bringing the methods that you want to be inherited by controllers or even views:

   class ApplicationController < ActionController::Base
     helper_method :show #this will make it eccessable to the views as well as controllers
     protect_from_forgery with: :exception
   
   
   end
#__________________________________________________________________________________________

#
#                                Rails Routing from the Outside In
#
#               Questions
#
# Q: What paths are automatically generated when using resources :users ?
# A: All the paths that would correspond the actions in your User_controller, which you can check by raking your routes.
#______________________________________________
# Q: Provide two ways you can see your routes. I don't mean the config/routes.rb file. How can you see the associated HTTP verb, the path, the controller#action, and the url_helper for each route in your application?
# A: In terminal run "rake routs" or in your web browser: "localhost3000/rails/info/routes"
#    URL_helper: provides a set of methods for making links and getting URLs that depend on the routing subsystem (see ActionController::Routing). This allows you to use the same format for links in views and controllers.

#----------------------------------------------
# Q: How do you set the root of your application?
# A: Using routes method 'root' and the controller#action pair that u want to land on:
# e.g
      config/routes.rb:
      root 'welcome#index'  #NB: The root route only routes GET requests to the action.
#-----------------------------------------------------
# Q: How can you customize your routes?
# A: You can use the rocket syntax.
# e.g:
# 
       get 'profiles/posts', :to => 'profiles#posts_index'
#-----------------------------------------------------
#
# Q: How can you limit the format of what gets entered into the ':id' parameter of the following path: '/products/:id' ?
