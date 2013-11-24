module Bukin
  class FileMatch

    def initialize(search)
      @search = search
    end

    def match(file_name)
      match_helper(@search, file_name)
    end

    alias_method :=~, :match

    def self.any
      FileMatch.new(true)
    end

  private
    def match_helper(search, file_name)
      if search == true || search == false
        search
      elsif search.is_a? ::String
        search == file_name
      elsif search.is_a? ::Regexp
        search =~ file_name
      elsif search.respond_to? :any?
        search.any? {|item| match_helper(item, file_name)}
      else
        false
      end
    end
  end
end
