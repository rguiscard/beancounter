require 'csv'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome, :guide]

  def beancount
    @entries = current_user.entries.includes(postings: :account).order("date DESC")
  end

  def statistics
    if params[:date].present? && (@date = DateTime.parse(params[:date]))
    else
      @date = DateTime.current
    end

    month = @date.month
    year = @date.year

    month_expense = current_user.expenses.find_by(year: year, month: month)
    if month_expense.blank? || (month_expense.updated_at < current_user.entries.maximum(:updated_at))
      ExpensesJob.perform_now(current_user, year, month)
    end

    year_expense = current_user.expenses.find_by(year: year, month: nil)
    if year_expense.blank? || (year_expense.updated_at < current_user.entries.maximum(:updated_at))
      ExpensesJob.perform_now(current_user, year, nil)
    end

    @current_month = current_user.expenses.find_by(year: year, month: month).try(:details)
    @current_year = current_user.expenses.find_by(year: year, month: nil).try(:details)
  end

  def guide
  end

  def welcome
  end
end
