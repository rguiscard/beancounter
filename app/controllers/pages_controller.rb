require 'csv'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome, :guide]

  def beancount
    @entries = current_user.entries.includes(postings: :account).order("date DESC")
  end

  def statistics
    ExpensesJob.perform_now(current_user, DateTime.current.year, DateTime.current.month)

    @current_month = current_user.expenses.find_by(year: DateTime.current.year, month: DateTime.current.month).details
  end

  def guide
  end

  def welcome
  end
end
