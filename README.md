# Beancounter

This is a Rails application to view and input financial data in [Beancount](http://furius.ca/beancount/). The main purpose is to facilitate writing and querying Beancount entries instead of replacing it. Therefore, it will not automatically fix any error when adding entries. Check syntax validation if it does not output proper results.

# Installation

### Change secret

Please change [Rails credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials) when deploying your own instance. The current plain credentials are:

````
# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: # paste results from 'bin/rails secret' here.
````

### Manual

1. Install beancount via package manager such as `pip3 install beancount`. Be sure that beancount and python libraries are in the environmental variables such as $PATH and $PYTHONPATH.
2. Install Rails and gems by `bundle install`
3. Edit database configuration in `config/database.yml` and create database by `rake db:setup`
4. Create a user through Rails console by `User.create(email: 'your@email.com', password: '1234', password_confirmation: '1234')`
5. Start Rails application and log in with above email and password

````
    RAILS_ENV=production bundle exec rails server
````

### Heroku

1. Create app
2. Add `RAILS_MASTER_KEY` variable
3. Add PostgreSQL and Redis as add-ons
4. `heroku git:remote -a app_name`
5. `git push heroku master`
6. Add python buildpack by `heroku buildpacks:add heroku/python`
7. Migrade database by `heroku run rake db:migrate`
8. Create user through Rails console (`heroku run rails c`) by `User.create(email: 'your@email.com', password: '1234', password_confirmation: '1234')`
9. You may need to `git push heroku master` again to trigger building.

### Docker

A Dockefile is included, which is used to deploy this application to DigitalOcean droplet via [Caprover](https://caprover.com/)

# Usage

For experienced beancount user, data can be input as regular plain-text beancount entries. Accounts should be opened by Beancount directive first before any other entries. For convenience, it can automatically create missing account by 'open' directive if entires contain accounts which are not existed yet.

Use **INPUT** on top-right navigation menu.
![Main Page](https://user-images.githubusercontent.com/48430375/85368188-5f14b500-b55d-11ea-92b7-1db9c9113f69.png)

Input Beancount entires as usual
![Input entries](https://user-images.githubusercontent.com/48430375/85368207-69cf4a00-b55d-11ea-9d42-ed15d1e572a5.png)

If accounts do not exist yet, check the box to create ones automatically. It will add entries with `open` directive.

For regular user, create the accounts and entries by web interface. Just remember to include currency whenever amount is inputed.

Find **NEW ACCOUNT** under **ACCOUNTS** menu.
![New Account](https://user-images.githubusercontent.com/48430375/85370517-6b027600-b561-11ea-93ac-d465dbd7a9fa.png)

Name account according to Beancount rule. If nickname is available, it will be displayed in most of places. For account with existing balance, entries with `pad` and `balance` directive will be created along with `open`.
![Create Account](https://user-images.githubusercontent.com/48430375/85370571-7bb2ec00-b561-11ea-993d-e355c229d8ab.png)

Create entry via **NEW ENTRY** button on top-left corner. It is mainly for common transaction from one account to another. Remember the currency for amount.
![Create Entry](https://user-images.githubusercontent.com/48430375/85370616-8cfbf880-b561-11ea-9e15-e867219a584d.png)

Created entry will look like a beancount transaction.
![Entry](https://user-images.githubusercontent.com/48430375/85370643-984f2400-b561-11ea-8254-21724dbefc93.png)

For more complicated transaction and entry, use **INPUT** for text input.

Syntax validation can be found in **validation** action of **BEANCOUNT** page at the bottom right page. 

# License

MIT

