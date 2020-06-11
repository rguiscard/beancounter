module SearchService
  class Base
    include ActiveModel::Model

    TOKEN_REGEX = /'.*?'|".*?"|\S+/ # consider quate

    def initialize(target = nil)
      @target = target
      @predicates = {
        title: :contains,
        description: :contains,
        content: :contains
      }
    end

    def search(query: nil) # take params[:q] in normal case
      return @target if query.blank?

      result = @target

      query.each do |key, value|
        next if value.blank?
        k = key.to_s.gsub(/[^A-Za-z_]/, '')
        m = "search_#{k}".to_sym
        if respond_to?(m)
          result = send(m, result, value)
        elsif predicate = @predicates[k.to_sym]
          query_field = ActiveRecord::Base.connection.quote_table_name("#{@target.klass.table_name}.#{k}")
          case predicate
          when :contains
            # PostgreSQL only
            #   Not sure quotation is necessary
            tokens = query_value_to_array(value)
            tokens = tokens.map { |s| "%#{s}%" }
            result = result.where("#{query_field} ILIKE ALL (array[?])", tokens)
          when :is_true
            result = result.where("#{query_field} = ?", !!ActiveRecord::Type::Boolean.new.type_cast_from_database(value))
          else
          end
        end
      end

      result
    end

    def search_full_text(target, value, fields = [:title, :description, :content])
      # PostgreSQL only
      tokens = query_value_to_array(value).map { |s| "%#{s}%" }
      query = fields.collect do |key| 
        query_field = ActiveRecord::Base.connection.quote_table_name("#{@target.klass.table_name}.#{key}")
        "(#{query_field} ILIKE ALL (array[?]))"
      end.join(" OR ")
      target.where(query, *([tokens]*fields.count))
    end

    def search_tags(target, tags)
      target.try(:with_all_tags, tags)
    end

    def search_tag(target, tag)
      search_tags(target, tag)
    end

    def query_value_to_array(value)
      tokens = []
      if value.kind_of?(String)
        tokens = value.scan(TOKEN_REGEX)
      elsif value.kind_of?(Array)
        tokens = value.flatten
      else
        puts "Token #{tokens} is not String nor Array"
      end
      tokens.compact
    end

    # return a hash as params[:q]
    def self.parse_keyword_search(search_string)
      hash = {}
      search_string.split(' ').each do |term|
        a = term.split(':')
        case a.count
        when 1
          if a[0].include? '<'
            # Time related
          elsif a[0].include? '>'
            # Time related
          else
            hash[:full_text] = [hash[:full_text], a[0].strip].join(' ').strip
          end
        when 2
          hash[a[0].to_sym] = [hash[a[0].to_sym], a[1].strip].join(' ').strip
        end
      end
      ActionController::Parameters.new(hash)
    end
  end

  class Entry < Base
    def initialize(target = nil)
      super
      @predicates[:arguments] = :contains
    end

    def search_date(target, value)
      target.where(date: Date.parse(value).all_day)
    end
  end

  class Posting < Base
    def initialize(target = nil)
      super
    end
  end
end
