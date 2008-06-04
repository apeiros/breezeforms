require 'cgi'


module HashHelper
	EmptyString = ''.freeze
	
	# Converts the hash to a list of attributes
	# with a leading space, so you can use it like:
	# "<foo#{attr_hash.tag_attributes}>" # => '<foo bar="baz">
	# keys and values must respond to to_s.
	def tag_attributes
		map { |k,v| %{ #{k}="#{::CGI.escapeHTML(v.to_s)}"} }.join(EmptyString)
	end
end

module StringHelper
	def escape_html
		::CGI.escapeHTML(self)
	end
end

class String
	include StringHelper
end

class Hash
	include HashHelper
end

module Ramaze
	class Controller
		alias controller class
	end
end

module Sequel
  class Dataset
    # Returns a paginated dataset. The resulting dataset also provides the
    # total number of pages (Dataset#page_count) and the current page number
    # (Dataset#current_page), as well as Dataset#prev_page and Dataset#next_page
    # for implementing pagination controls.
    def paginate(page_no, page_size)
      raise(Error, "You cannot paginate a dataset that already has a limit") if @opts[:limit]
      record_count = count
      total_pages = record_count.zero? ? 1 : (record_count / page_size.to_f).ceil
      raise(Error, "page_no must be > 0") if page_no < 1
      paginated = limit(page_size, (page_no - 1) * page_size)
      paginated.extend(Pagination)
      paginated.set_pagination_info(page_no, page_size, record_count)
      paginated
    end

    module Pagination
      # Returns true if this page is the first page
      def first_page?
      	@current_page == 1
      end

			# Returns true if this page is the last page
      def last_page?
      	@current_page == @page_count
      end
      
      # Sets the pagination info
      def set_pagination_info(page_no, page_size, record_count)
        @current_page = page_no
        @page_size = page_size
        @pagination_record_count = record_count
        @page_count = record_count.zero? ? 1 : (record_count / page_size.to_f).ceil
      end
    end
  end
end
