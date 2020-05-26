class PagesController < ApplicationController
  def beancount
  end

  def input
    @errors = nil
  end

  def import
    @content = params[:content]
    @errors = ParseService.validate(@content)
    respond_to do |format|
      if @errors.blank?
        ParseService.parse(@content) do |output|
          p output
        end
        format.html { redirect_to entries_path }
      else
        format.html { redirect_to pages_input_path, notice: @errors.join("; ") }
      end
    end
  end
end
