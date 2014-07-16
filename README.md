# Can I Eat Here?

Can I Eat Here is a web app for finding restaurants that provide food you can
consume; in spite of your restrictions.

## Learning Goals


## Using This Repo
This repo is to serve as a reference for how to iteratively build web
applications in Sinatra.

I would recommend reading this repository [commit by
commit](https://github.com/codeunion/can-i-eat-here/commits/master) in github.
Add comments asking questions on lines of code.


## Functional Requirements

1. A guest may register as a User
1. A User may create a Restaurant
1. A User may create a Restriction
1. A User may tag a Restaurant With a SupportedRestriction
1. A User may search for Restaurants by SupportedRestriction
1. A User may search for Restaurants by Location


## Running The Software

1. Clone the repo
2. `bundle install --without production`
3. `rerun -c rackup`
4. Open it in your browser!


## Deploying The Software

1. [Install the Heroku
   Toolbelt](https://devcenter.heroku.com/articles/quickstart#step-2-install-the-heroku-toolbelt)
1. `heroku create`
1. `git push heroku`
1. `heroku open`
