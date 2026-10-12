class CaptureLead
  class ContactConflict < StandardError; end

  def self.call(chat:, attributes:)
    new(chat, attributes).call
  end

  def initialize(chat, attributes)
    @chat      = chat
    @widget    = chat.chat_widget
    @candidate = @widget.leads.build(attributes)
  end

  def call
    raise ActiveRecord::RecordInvalid, @candidate unless @candidate.valid?

    # Serialize matching and creation within a widget; unique indexes also guard duplicates.
    @widget.with_lock do
      @chat.reload
      lead = resolve_lead
      fill_missing_contacts(lead)
      @chat.update!(lead: lead)
      lead
    end
  end

  private

  def resolve_lead
    matches = matching_leads
    if matches.size > 1 || (@chat.lead_id.present? && matches.first&.id != @chat.lead_id)
      raise ContactConflict, 'Не удалось связать контакты. Проверьте данные или обратитесь к менеджеру в чате.'
    end

    matches.first || @candidate
  end

  def matching_leads
    %i[phone email].filter_map do |field|
      value = @candidate.public_send(field)
      @widget.leads.find_by(field => value) if value.present?
    end.uniq(&:id)
  end

  def fill_missing_contacts(lead)
    # Public submissions can fill missing contacts, but cannot overwrite existing ones.
    lead.phone ||= @candidate.phone
    lead.email ||= @candidate.email
    lead.save!
  end
end
