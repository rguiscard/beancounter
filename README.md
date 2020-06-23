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

Find **NEW ACCOUNT** under **ACCOUNTS** menu.
![New Account](https://user-images.githubusercontent.com/48430375/85370517-6b027600-b561-11ea-93ac-d465dbd7a9fa.png)

Name account according to Beancount rule. If nickname is available, it will be display in most of places. For account with existing balance, entries with `pad` and `balance` directive will be created along with `open`.
![Create Account](https://user-images.githubusercontent.com/48430375/85370571-7bb2ec00-b561-11ea-993d-e355c229d8ab.png)

Create entry via **NEW ENTRY** button on top-left corner. It is mainly for common transaction from one account to another. Remember the currency for amount.
![Create Entry](https://user-images.githubusercontent.com/48430375/85370616-8cfbf880-b561-11ea-9e15-e867219a584d.png)

Created entry will look like a beancount transaction.
![Entry](https://user-images.githubusercontent.com/48430375/85370643-984f2400-b561-11ea-8254-21724dbefc93.png)

For more complicated transaction and entry, use **INPUT** for text input.

# License

MIT

