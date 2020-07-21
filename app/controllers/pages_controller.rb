require 'csv'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome, :guide]

  def beancheck
    path = Pathname.new(current_user.save_beancount)

    @errors = Rails.cache.fetch(["validation", current_user.cache_key, current_user.beancount_cached_at]) do
      %x(bean-check #{path} 2>&1)
    end
  end

  def beancount
    @entries = current_user.entries.order("date DESC")
    if params[:q].present? && @search_params = params.require(:q)
      if @search_params.kind_of?(String)
        @search_params = SearchService::Base.parse_keyword_search(@search_params)
      end
      @entries = SearchService::Entry.new(@entries).search(query: @search_params)
    end
  end

  def trend
    @asset = params[:asset] || "Assets"

    if (@trend = current_user.trends.find_by(name: @asset)) && (@trend.updated_at > DateTime.current-23.hours)
    else
      AssetTrendJob.perform_now(current_user, @asset)
      @trend = current_user.trends.find_by(name: @asset)
    end

    @content = @trend.data

    @records = []

    CSV.parse(@content, headers: :first_row, converters: ->(f) { f.strip }).each do |row|
      @records << {date: DateTime.new(row['year'].to_i, row['month'].to_i, 1), sum: row['sum'], balance: row['balance']}
    end

    # Fill up each month
    # rows = CSV.parse(@content, {headers: :first_row, converters: ->(f) { f.strip}})
    # first = rows.first
    # current = DateTime.new(first['year'].to_i, first['month'].to_i, 1)
    #
    # @records << {date: current, sum: first['sum'], balance: first['balance']}
    # rows.each do |row|
    #   date = DateTime.new(row['year'].to_i, row['month'].to_i, 1)
    #   while (current < date) do
    #     current = current+1.month
    #     @records << {date: current, sum: row['sum'], balance: row['balance']}
    #   end
    # end

    # list of account and sub-accounts
    @accounts = current_user.accounts
    @arr = []
    @accounts.collect do |account|
      x = account.name.split(':')
      parent = nil
      (0..x.size-1).each do |n|
        y = x[0..n].join(':')
        @arr << y
      end
    end
    @arr.uniq!
    @arr
  end

  def statistics
    if params[:date].present? && (@date = DateTime.parse(params[:date]))
    else
      @date = DateTime.current
    end

    @previous_month = @date.beginning_of_month-1.month

    @current_month_data = periodic_data(year: @date.year, month: @date.month)
    @previous_month_data = periodic_data(year: @previous_month.year, month: @previous_month.month)
    @current_year_data = periodic_data(year: @date.year, month: nil)
  end

  def guide
  end

  def welcome
  end

  private

    def periodic_data(year:, month: nil)
      data = []
      if current_user.entries.empty?
      else
        expense = current_user.expenses.find_by(year: year, month: month)
        if expense.blank? || (expense.updated_at < current_user.entries.maximum(:updated_at))
          ExpensesJob.perform_now(current_user, year, month)
        end
        if (expense = current_user.expenses.find_by(year: year, month: month).try(:details)) && expense.present?
          data = CSV.parse(expense, headers: :first_row, converters: ->(f) { f.strip }).to_a[1..-1].to_h
        end
      end
      data
    end
end
