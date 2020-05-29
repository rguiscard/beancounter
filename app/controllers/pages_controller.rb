class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome, :guide]

  def beancount
    @entries = current_user.entries.includes(postings: :account).order("date DESC")
  end

  def statistics
  end

  def guide
  end

  def welcome
  end
end
