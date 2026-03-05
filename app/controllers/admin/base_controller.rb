module Admin
  class BaseController < ApplicationController
    include Pagy::Method
    include ResourceConcerns

    before_action :authenticate_user!

    layout 'admin'
  end
end
