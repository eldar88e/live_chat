class PwaController < ApplicationController
  skip_forgery_protection

  def not_found
    # render :not_found, status: :not_found
    respond_to do |format|
      format.html { render :not_found, status: :not_found }
      format.any  { head :not_found }
    end
  end

  def offline; end
end
