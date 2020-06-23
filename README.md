# Beancounter

This is a Rails application to view and input finantial data in [Beancount](http://furius.ca/beancount/).

# Installation

### Manual

1. Install beancount via package manager such as `pip3 install beancount`
2. Install Rails and gems by `bundle install`
3. Edit database configuration and and create database
4. Create a user through Rails console like this `User.create(username: 'your@email.com', password: '1234', password_confirmation: '1234')
5. Start Rails application and log in with above username and password

### Docker

A Dockefile is included, which is used to deploy this application to DigitalOcean droplet via [Caprover](https://caprover.com/)

# Usage

For experienced beancount user, data can be input as regular plain-text beancount entries. Accounts should be opened by Beancount directive first before any other entries. For convenience, it can automatically create missing account by 'open' directive if entires contain accounts which are not existed yet.

For regular user, create the accounts and entries by web interface. Just remember to include currency whenever amount is inputed.

# License

MIT

