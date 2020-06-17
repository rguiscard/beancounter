require 'csv'

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :settings, :confirm_destroy, :complete_destroy]
  after_action :delete_beancount, only: [:update, :create, :destroy, :complete_destroy]

  # If there are postings associated with account, redirect to here
  def confirm_destroy
    @entries = current_user.entries.with_account(@account)
  end

  # remove both associated entries and account
  def complete_destroy
    @entries = current_user.entries.with_account(@account)
    @entries.destroy_all
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /accounts/1/settings
  def settings
    @entries = @account.associate_entries
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

        # Create corresponding entries
        date = (params[:date].blank? ? DateTime.current : DateTime.parse(params[:date]))
        current_user.entries.create(date: date-1.day, directive: :open, arguments: "#{@account.name} #{@account.currency_list}")
        if (amount = Amount.new(params[:balance])) && (amount.blank? == false) && (amount.number != 0)
          equity_setup = 'Equity:Setup'
          equity = current_user.accounts.find_or_create_by(name: equity_setup) do |account|
            equity = current_user.entries.create(date: date-1.day, directive: :open, arguments: account.name)
          end
          current_user.entries.new(date: date-1.day, directive: :pad, arguments: "#{@account.name} #{equity.name}")
          current_user.entries.new(date: date, directive: :balance, arguments: "#{@account.name} #{params[:balance]}")
        end

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
end
