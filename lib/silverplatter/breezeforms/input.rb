#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/adaptors'
require 'silverplatter/breezeforms/input'
require 'silverplatter/breezeforms/textarea'
require 'silverplatter/breezeforms/button'
require 'silverplatter/breezeforms/select'
require 'silverplatter/validators'



module SilverPlatter
	module BreezeForms

		# == Example
		#   MyInput = Input.text do
		#     attributes    :size => 3
		#     named         "port"
		#     expecting     Integer
		#     with_default  "80"
		#     validates_if  :natural, :less_than => 65535
		#     falls_back_to :userinput
		#   end
		#   
		#   input = MyInput.new(submitted_value)
		#   input.valid?
		#   input.value
		class Input
			class <<self
				alias class_name name

				EmptyValue     = "".freeze
				DefaultOptions = {
					:expecting          => String,
					:prefixed           => "".freeze,
					:defaults_to        => "".freeze,
					:falls_back_to      => :original,
					:validates_if       => {},
					:attributes         => {},
					:on_valid           => {},
					:on_error           => {},
					:add_class_on_error => {},
				}.freeze
				InspectClass = "#<%s %s %p, default=%p, fallback=%p expects=%p, restrictions=%p>".freeze

				def create(*args, &block)
					input = Class.new(self)
					input.init(*args, &block)
					input
				end
				
				attr_reader :type
				attr_reader :name
				attr_reader :attributes
				attr_reader :default
				attr_reader :fallback
				def init(type=nil, name=nil, opt=nil, &block)
					opt           = DefaultOptions.merge(opt || {})
					@name         = name
					@type         = type
					@prefix       = opt.delete(:prefixed)
					@expects      = opt.delete(:expecting)
					@default      = opt.delete(:defaults_to)
					@attributes   = opt.delete(:attributes)
					@on_error     = opt.delete(:on_error)
					@on_valid     = opt.delete(:on_valid)
					@fallback     = opt.delete(:falls_back_to)
					@restrictions = opt.delete(:validates_if)
					@validator    = opt.delete(:validator)

					class_eval(&block) if block
					
					raise ArgumentError.new("Name and Type must be given") unless @name && @type

					extend Adaptors::Adaptors[@expects]
					extend Validators::Validators[@expects]
				end
				
				def attributes(*args)
					until args.empty?
						@attributes[args.shift] = true while args.first.kind_of?(Symbol)
						@attributes.update(args.shift)
					end
					@attributes
				end
				
				def on_valid(&block)
					@on_valid = DSL::OnErrorOrValid.new(&block).__hash__ if block
					@on_valid
				end
				
				def on_error(&block)
					@on_error = DSL::OnErrorOrValid.new(&block).__hash__ if block
					@on_error
				end
				
				def named name
					@attributes[:name] = name
				end
				
				def of_type(type)
					@type = type
				end
				
				def prefixed(prefix)
					@prefix = prefix
				end
				
				def defaults_to value
					@default = value
				end
	
				def expecting klass
					@expect  = klass
				end

				def validates_if *args, &block
					@restrictions = args[0] unless args.empty? 
					@validator    = block
				end

				def select;end
				def optgroup;end
				def option;end
				def button;end
				def textarea(*args, &block); Textarea.create(*args, &block);   end
				def text(*args, &block);     create(:text, *args, &block);     end
				def password(*args, &block); create(:password, *args, &block); end
				def checkbox(*args, &block); create(:checkbox, *args, &block); end
				def radio(*args, &block);    create(:radio, *args, &block);    end
				def submit(*args, &block);   create(:submit, *args, &block);   end
				def reset(*args, &block);    create(:reset, *args, &block);    end
				def file(*args, &block);     create(:file, *args, &block);     end
				def hidden(*args, &block);   create(:hidden, *args, &block);   end
				def image(*args, &block);    create(:image, *args, &block);    end
				def button(*args, &block);   create(:button, *args, &block);   end

				def fallback_value(value)
					case @fallback
						when :original
							value
						when :default
							@default
						when :empty
							EmptyValue
						when Proc
							@fallback.call(value,self)
					end
				end				

				def new(original)
					errors    = []
					value     = nil
					available = !original.nil?
					
					if available then
						begin
							value  = adapt(original)
						rescue AdaptionError => error
							errors << error
						else
							@restrictions.each { |m, args|
								begin
									value = __send__(m, value, *args) # fastfail, don't continue validating if one fails
								rescue ValidationError => error
									errors << error
									break
								rescue NoMethodError
									raise ArgumentError, "Invalid validation #{m} in definition of #{self}"
								end
							}
							if errors.empty? && @validator then
								begin
									value = @validator.call(value)
								rescue AdaptionError, ValidationError => error
									errors << error
								rescue => e
									errors << ValidationError.new(:block_validation_failed, value, :exception => e)
								end
							end
							value = errors.empty? ? value : fallback_value(value)
						end
					end

					super(available, original, value, errors)
				end

				def html_name
					"#{@prefix}#{@name}"
				end

				def inspect # :nodoc:
					sprintf InspectClass,
						superclass.class_name, # FIXME breaks for its own class (BreezeForms::Input) - hardcode?
						@type,
						html_name,
						@default,
						@fallback,
						@expects,
						@restrictions
					# /sprintf
				end
			end
			
			InspectInstance = "#<%s:%s name=%p %s value=%p, original=%p, default=%p, fallback=%p>".freeze
			IndentString    = "\t".freeze

			attr_reader :original
			attr_reader :errors
			attr_reader :value
			attr_reader :original

			# adapts and validates value, returns a Validator::Value instance
			def initialize(available, original, value, errors)
				@original  = original
				@value     = value
				@available = available
				@valid     = available && errors.empty?
				@errors    = errors
			end
			
			alias input class

			def valid?
				@valid
			end

			def available?
				@available
			end

			# A field is erroneous if it is available and not valid
			# or if it is not available and required.
			def erroneous?
				@available && !@valid
			end

			def html_name
				input.html_name
			end
			
			def name
				input.name
			end
			
			def prefix
				input.prefix
			end
			
			def default
				input.default
			end

			def fallback
				input.fallback
			end

			# The value that should be inserted into the HTML tag
			# Also see to_html.
			def html_value
				if @valid then
					@value
				elsif erroneous? && input.fallback == :original then
					@original
				else
					input.default
				end
			end

			# Create an HTML tag for this Input.
			# Also see html_value.
			def to_html(indent=0, indent_str=IndentString)
				attributes = input.attributes.dup
				if erroneous? then
					if input.on_error[:attributes] then
						attributes.update(input.on_error[:attributes])
					end
					if input.on_error[:add_class] then
						attributes[:class] = "#{attributes[:class]} #{input.on_error[:add_class]}".strip
					end
				elsif valid? then # a field can be neither (when it's loaded the first time)
					if input.on_valid[:attributes] then
						attributes.update(input.on_valid[:attributes])
					end
					if input.on_valid[:add_class] then
						attributes[:class] = "#{attributes[:class]} #{input.on_valid[:add_class]}".strip
					end
				end
				attributes.update({
					"type"  => input.type,
					"name"  => input.html_name,
					"value" => html_value
				})
				attributes = attributes.map { |key, value| "#{key}=\"#{value.to_s.escape_html}\"" }.join(" ")
				"#{indent_str*indent if indent}<input #{attributes} />"
			end
			alias to_s to_html
			
			def inspect #:nodoc:
				sprintf InspectInstance,
					input.superclass.class_name,
					input.type,
					html_name,
					@valid ? 'valid' : 'invalid',
					value,
					original,
					default,
					fallback
				# /sprintf
			end
		end
	end
end
