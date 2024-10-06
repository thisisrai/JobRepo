class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.is_a?(Hash)
      record.errors.add(attribute, 'must be a valid JSON object')
    end
  rescue JSON::ParserError
    record.errors.add(attribute, 'must be valid JSON')
  end
end
