class Admin::FaqCategoriesController < AdminController
  include Admin::FaqHelper

  before_action :set_faq_category, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  # GET /admin/faq_categories
  def index
    @faq_categories = FaqCategory.includes(:faqs).all
  end

  # GET /admin/faq_categories/1
  def show
  end

  # GET /admin/faq_categories/new
  def new
    max_rank = FaqCategory.maximum("rank") ? FaqCategory.maximum("rank") : 0
    @faq_category = FaqCategory.new(rank: max_rank + 10)
  end

  # GET /admin/faq_categories/1/edit
  def edit
  end

  # POST /admin/faq_categories
  def create
    @faq_category = FaqCategory.new(category_params)

    respond_to do |format|
      if @faq_category.save
        format.html { redirect_to admin_faq_categories_url, notice: 'Category was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /admin/faq_categories/1
  def update
    respond_to do |format|
      if @faq_category.update(category_params)
        format.html { redirect_to admin_faq_categories_url, notice: 'Category was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/faq_categories/1
  def destroy
    @faq_category.destroy
    respond_to do |format|
      format.html { redirect_to admin_faq_categories_url, notice: 'Category was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_faq_category
      @faq_category = FaqCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:faq_category).permit(:name, :rank)
    end
end
