class PostingsController < ApplicationController
  before_action :set_entry
  before_action :set_posting, only: [:show, :edit, :update, :destroy]
  after_action :delete_beancount, only: [:update, :create, :destroy]

  # GET /postings
  # GET /postings.json
  def index
    @postings = @entry.postings.all
  end

  # GET /postings/1
  # GET /postings/1.json
  def show
  end

  # GET /postings/new
  def new
    @posting = Posting.new
  end

  # GET /postings/1/edit
  def edit
  end

  # POST /postings
  # POST /postings.json
  def create
    @posting = @entry.postings.new(posting_params)

    respond_to do |format|
      if @posting.save
        format.html { redirect_to @entry, notice: 'Posting was successfully created.' }
        format.json { render :show, status: :created, location: @posting }
      else
        format.html { render :new }
        format.json { render json: @posting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /postings/1
  # PATCH/PUT /postings/1.json
  def update
    respond_to do |format|
      if @posting.update(posting_params)
        format.html { redirect_to @entry, notice: 'Posting was successfully updated.' }
        format.json { render :show, status: :ok, location: @posting }
      else
        format.html { render :edit }
        format.json { render json: @posting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /postings/1
  # DELETE /postings/1.json
  def destroy
    @posting.destroy
    respond_to do |format|
      format.html { redirect_to @entry, notice: 'Posting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = current_user.entries.find(params[:entry_id])
    end

    def set_posting
      @posting = @entry.postings.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def posting_params
      params.require(:posting).permit(:flag, :account_id, :arguments, :comment, :entry_id)
    end

    # remove beancount cache from user
    def delete_beancount
      current_user.delete_beancount
    end
end
