module Admin
  class ErrorsController < BaseController
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    skip_before_action :set_resource, only: :show
    before_action :set_service, :set_items

    def index; end

    def show
      @item = @items.find { |i| i['id'].to_s == params[:id] }
      raise ActiveRecord::RecordNotFound if @item.blank?

      @errors = cached_errors
      @error  = find_error
    end

    private

    def find_error
      params['item'].present? ? @errors.find { |i| i['id'] == params['item'].to_i } : @errors.first
    end

    def authorize_user!
      authorize %i[admin error], :"#{action_name}?"
    end

    def set_service
      @service = Admin::RollbarService.new
    end

    def set_items
      @items = Rails.cache.fetch(:error_items, expires_in: 10.minutes) { @service.items }
      raise ActiveRecord::RecordNotFound if @items.blank?

      @items
    end

    def cached_errors
      Rails.cache.fetch("errors_#{params[:id]}", expires_in: 5.minutes) { @service.instances(params[:id]) }
    end
  end
end
