class PwaController < ApplicationController
  skip_forgery_protection
  layout false, except: :not_found

  def service_worker
    return render js: '' if Rails.env.development?

    expires_now
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    render template: 'pwa/service_worker', formats: :js, content_type: 'application/javascript'
  end

  def manifest
    expires_now
    response.headers['Cache-Control'] = 'no-store'
    render template: 'pwa/manifest'
  end

  def not_found
    render :not_found, layout: 'application', status: :not_found, formats: :html
  end

  def offline
    render :offline, layout: 'application'
  end
end
