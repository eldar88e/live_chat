module MainConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :settings
  end

  private

  def error_notice(msg, status = :unprocessable_content)
    render turbo_stream: send_notice(msg, 'danger'), status:
  end

  def success_notice(msg)
    send_notice(msg, 'success')
  end

  def send_notice(msg, key)
    turbo_stream.append(:notices, partial: '/layouts/partials/notices/notice', locals: { notices: msg, key: })
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def settings
    @settings_ ||= Setting.all_cached
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName
end
