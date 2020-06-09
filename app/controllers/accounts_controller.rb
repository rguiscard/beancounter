require 'csv'

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :settings, :confirm_destroy, :complete_destroy]
  after_action :delete_beancount, only: [:update, :create, :destroy, :complete_destroy]

  # If there are postings associated with account, redirect to here
  def confirm_destroy
    @entries = associated_entries
  end

  # remove both associated entries and account
  def complete_destroy
    associate_entries_to_account(@account)
    @entries = associated_entries # associated through postings
    @entries.destroy_all
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /accounts/1/settings
  def settings
    associate_entries_to_account(@account)
  end

  # GET /accounts
  # GET /accounts.json
  def index
    if current_user.beancount_cached_at.blank? || ((current_user.entries.empty? == false) && (current_user.balances.empty? == false) && (current_user.balances.maximum(:updated_at) < current_user.entries.maximum(:updated_at)))
      AccountBalanceJob.perform_now(current_user)
    end
    @accounts = current_user.accounts.includes(:balances).order("name ASC")
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    if @account.journal_cached_at.blank? || @account.journal.blank? ||
       (@account.journal_cached_at.present? && (current_user.entries.empty? == false) && (current_user.entries.maximum(:updated_at) > @account.journal_cached_at))
      AccountJournalJob.perform_now(current_user, @account)
    end
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = current_user.accounts.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    associate_entries_to_account(@account)
    if @account.postings.empty?
      @account.destroy
      respond_to do |format|
        format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to confirm_destroy_account_path(@account)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = current_user.accounts.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :booking, :currency_list, :nickname)
    end

    # remove beancount cache from user
    def delete_beancount
      current_user.delete_beancount
    end

    # Entries having postings associated with account.
    # Do not confuse with entries which directly associate with account, such as open, pad and balance directive
    def associated_entries
      @current_user.entries.joins(postings: :account).where(:"postings.account" => @account)
    end

    def associate_entries_to_account(account)
      # try to find all entries related to this account.
      @entries = current_user.entries.where(directive: ['open', 'balance', 'pad', 'close'])
      @entries = @entries.where("arguments ilike ?", "#{account.name} %").or(@entries.where(arguments: account.name))
      @entries.where(account: nil).update_all(account_id: account.id)
    end
end
