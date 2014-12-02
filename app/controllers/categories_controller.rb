class CategoriesController < ApplicationController

  def show
    @category = Category.find(params[:id])
    @beliefs = @category.beliefs.order(user_count: :desc)
    @results = @beliefs
  end


end
