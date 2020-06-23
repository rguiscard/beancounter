# Beancounter

This is a Rails application to view and input financial data in [Beancount](http://furius.ca/beancount/).

# Installation

### Manual

1. Install beancount via package manager such as `pip3 install beancount`
2. Install Rails and gems by `bundle install`
3. Edit database configuration in `config/database.yml` and create database by `rake db:setup`
4. Create a user through Rails console by `User.create(username: 'your@email.com', password: '1234', password_confirmation: '1234')
5. Start Rails application and log in with above username and password

````
    RAILS_ENV=production bundle exec rails start
````

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

# License

MIT

