require 'csv'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome, :guide]

  def beancount
    @entries = current_user.entries.includes(postings: :account).order("date DESC")
  end

  def statistics

    month_expense = current_user.expenses.find_by(year: DateTime.current.year, month: DateTime.current.month)
    if month_expense.updated_at < current_user.entries.maximum(:updated_at)
      ExpensesJob.perform_now(current_user, DateTime.current.year, DateTime.current.month)
    end

    year_expense = current_user.expenses.find_by(year: DateTime.current.year, month: nil)
    if year_expense.updated_at < current_user.entries.maximum(:updated_at)
      ExpensesJob.perform_now(current_user, DateTime.current.year, nil)
    end

    @current_month = month_expense.details
    @current_year = year_expense.details
  end

  def guide
  end

  def welcome
  end
end
