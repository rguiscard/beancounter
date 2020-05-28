class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome, :guide]

  def beancount
    @entries = current_user.entries.includes(postings: :account).order("date DESC")
  end

  def input
    @errors = nil
  end

  def import
    @content = params[:content]
    @errors = ParseService.validate(@content)
    respond_to do |format|
      if @errors.blank?
        entry = nil
        ParseService.parse(@content) do |klass, data|
          case klass
          when :entry
            entry = current_user.entries.create(date: Date.parse(data[:date]), directive: data[:directive], arguments: data[:arguments])
            if entry.open?
              current_user.accounts.create(name: data[:name])
            end
          when :posting
            if entry.present? && entry.transaction? && (account = Account.find_by(name: data[:account]))
              posting = entry.postings.create(account: account, arguments: data[:arguments], comment: data[:comment])
            else
              puts "Cannot save posting: #{data}"
            end
          else
            puts "Unknown type #{klass}: #{data}"
          end
        end
        format.html { redirect_to entries_path }
      else
        format.html { redirect_to pages_input_path, notice: @errors.join("; ") }
      end
    end
  end

  def guide
  end

  def welcome
  end
end
