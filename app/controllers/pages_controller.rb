class PagesController < ApplicationController
  def beancount
  end

  def import
  end

  def parse
    respond_to do |format|
      format.html { redirect_to entries_path }
    end
  end
end
