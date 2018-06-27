class Admin::FaqsController < AdminController
  include Admin::FaqHelper

  before_action :set_faq, only: [:edit, :update, :destroy]

  layout 'admin'

  # GET /admin/faqs/new
  def new
    max_rank = Faq.maximum("rank") ? Faq.maximum("rank") : 0
    faq_category_id = params[:faq_category_id]
    @faq = Faq.new(faq_category_id: faq_category_id, rank: max_rank + 10)
  end

  # GET /admin/faqs/1/edit
  def edit
  end

  # POST /admin/faqs
  def create
    @faq = Faq.new(faq_params)

    respond_to do |format|
      if @faq.save
        format.html { redirect_to admin_faq_categories_url, notice: 'FAQ was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /admin/faqs/1
  def update
    respond_to do |format|
      if @faq.update(faq_params)
        format.html { redirect_to admin_faq_categories_url, notice: 'FAQ was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/faqs/1
  def destroy
    if false
      redirect_to admin_faq_categories_url, notice: 'FAQ was successfully destroyed.'
    else
      flash[:alert] = "Something went wrong"
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_faq
      @faq = Faq.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def faq_params
      params.require(:faq).permit(:question, :answer, :rank, :faq_category_id, :published)
    end
end
