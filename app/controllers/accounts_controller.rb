require 'csv'

class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  after_action :delete_beancount, only: [:update, :create, :destroy]

  def balances
    AccountBalanceJob.perform_now(current_user)

    respond_to do |format|
      format.html { redirect_to accounts_path, notice: 'Account balances refreshed.' }
    end
  end

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = current_user.accounts.assets.or(current_user.accounts.liabilities).includes(:balances).order("name ASC")
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    if @account.journal_cached_at.blank? || @account.journal.blank? ||
       (current_user.entries.maximum(:updated_at) > @account.journal_cached_at)
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
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = current_user.accounts.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:name, :booking, :currency_list)
    end

    # remove beancount cache from user
    def delete_beancount
      current_user.delete_beancount
    end
end
