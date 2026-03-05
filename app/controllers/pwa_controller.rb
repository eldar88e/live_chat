class PwaController < ApplicationController
  skip_forgery_protection

  def not_found
    render :not_found, status: :not_found
  end

  def offline; end
end
