class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy, :duplicate]
  after_action :delete_beancount, only: [:update, :create, :destroy, :import]

  def duplicate
    @content = @entry.bean_cache

    render :input
  end

  def search
  end

  def input
    @errors = nil
    @content = nil
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
              current_user.accounts.find_or_create_by(name: data[:name])
            end
          when :posting
            account = current_user.accounts.find_by(name: data[:account])
            if account.blank? && ActiveModel::Type::Boolean.new.cast(params[:create_account])
              account = current_user.accounts.create(name: data[:account])
              earliest = current_user.entries.minimum(:date)
              current_user.entries.create(date: earliest-1.day, directive: :open, arguments: data[:account]) 
            end
            if entry.present? && entry.transaction? && account.present?
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
        format.html { redirect_to input_entries_path, notice: @errors.join("; ") }
      end
    end
  end

  # only show transactions
  def transactions
    @entries = current_user.entries.transactions.includes(postings: :account).order("date DESC")
    @pagy, @entries = pagy(@entries, items: 30)
  end

  # GET /entries
  # GET /entries.json
  def index
    @entries = current_user.entries.includes(postings: :account)
    if params[:q].present? && @search_params = params.require(:q)
      if @search_params.kind_of?(String)
        @search_params = SearchService::Base.parse_keyword_search(@search_params)
      end
      @entries = SearchService::Entry.new(@entries).search(query: @search_params)
    end
    @entries = @entries.order("date DESC")
    @pagy, @entries = pagy(@entries, items: 30)
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @entry = Entry.new
    2.times { @entry.postings.build }
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = current_user.entries.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @entry, notice: 'Entry was successfully created.' }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to @entry, notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to entries_url, notice: 'Entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = current_user.entries.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      pm = params.require(:entry).permit(:date, :directive, :arguments, postings_attributes: [:account_id, :arguments])
      if ((pm[:directive] == "txn") || (pm[:directive] == "asterisk") || (pm[:directive] == "exclamation")) && pm[:arguments].start_with?('"') == false
        pm[:arguments] = "\"#{pm[:arguments]}\""
      end
      pm
    end

    # remove beancount cache from user
    def delete_beancount
      current_user.delete_beancount
    end
end
