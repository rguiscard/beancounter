class TagService
  SPLIT_REGEX = /[ ]*,[ ]*/.freeze
  SANITIZE_REGEX = /[^A-Za-z\-\_]/.freeze
  # convert string to array
  def self.parse tags
    result = []
    case tags
    when String
      result = tags.strip.split(SPLIT_REGEX)
    else
      result = tags
    end
    result.collect(&:strip)
  end

  def self.sanitize_tag_name(tag_name)
    tag_name.to_s.gsub(SANITIZE_REGEX, '')
  end
end
