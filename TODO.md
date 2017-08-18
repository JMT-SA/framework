# TODO

# Javascript

Look at using webpack - good thoughts for Rails 4 from here: https://revs.runtime-revolution.com/want-to-use-es6-with-rails-right-now-webpack-to-the-rescue-ebefb2004e9e#.ouv5jkmo5

# DB

Try out rom-roda?

# Route

Possibility of using boolean matchers to handle authorization:

~~~{.ruby}
# ...
  r.on 'search' do
    r.on :id do |id|
      r.on user.not_allowed(url, id)
        "Error - 404"
      end
      r.on 'filter' do
        'OK: filter'
      end
      r.on 'run' do
        'OK: run'
      end
    end
  end
~~~

# Hidden and Invisible

# CSRF tags

Must have csrf for rodauth to work, but then all other forms need to include csrf tag.
Roda plugin has csrf_tag method, but then it needs to be passed to our view code so it can be passed to the Crossbeams::Layout for rendering.
Implemented in show_page helper.

# Searching

* Move helpers into the data_grid plugin.
* Use plugin for dm portal too?
* JS...

# To create a new user via the console:

`bin/console`

~~~{.ruby}
require 'bcrypt'

usr_hash = {login_name: 'james',
            user_name: 'James Silberbauer',
            password_hash: BCrypt::Password.create(pass).to_s,
            created_at: Time.now,
            updated_at: Time.now
            }

user_repo.create(usr_hash)
~~~

# Dry validation

* Input from forms must use Form, not Schema
* Use the result.to_h hash instead of params to do updating.
* Therefore all form inputs **must** be listed - even if they're optional - and expected types given.
* Use specific data types for validation of numerics (int, float, decimal).

# Move to Sequel

* Set up migrations for existing tables.
* Apply migration triggers for created/updated dates.
* Remove all unused code referring to tables used in older experiments.
* Config for database connection & dev/production environments.
* Revert DB to a plain Sequel connection (remove .base etc) - effect on roda-grid plugin.
* Set up Rakefile for migrations.
