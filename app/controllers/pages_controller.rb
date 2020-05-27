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
        entry = nil
        ParseService.parse(@content) do |klass, data|
          case klass
          when :entry
            entry = Entry.create(date: Date.parse(data[:date]), directive: data[:directive], arguments: data[:arguments])
            if entry.open?
              Account.create(name: data[:name])
            end
          when :posting
            if entry.present? && entry.txn? && (account = Account.find_by(name: data[:account]))
              posting = entry.postings.create(account: account, amount: data[:amount], comment: data[:comment])
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
end
