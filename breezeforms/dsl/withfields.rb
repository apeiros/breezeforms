module Silverplatter
	module BreezeForms
		module DSL
			class WithFields
				attr_reader :__hash__
				attr_reader :form

				def initialize(&block)
					@form     = form
					@__hash__ = {}
					instance_eval(&block)
				end
			
				# Uses DSL::OnErrorOrValid, so those methods are valid within
				# the on_error block.
				# This block is applied to all subsequent field definitions.
				def on_error(&block)
					@on_error = OnErrorOrValid.new(&block).__hash__
				end
				
				# Uses DSL::OnErrorOrValid, so those methods are valid within
				# the on_valid block.
				# This block is applied to all subsequent field definitions.
				def on_valid(&block)
					@on_success = OnErrorOrSuccess.new(&block).__hash__
				end
				
				def select;end
				def button;end
				def textarea(name, *args, &block); Textarea.new(*args, &block);   end
				def text(name, *args, &block);     Input.text(*args, &block);     end
				def password(name, *args, &block); Input.password(*args, &block); end
				def checkbox(name, *args, &block); Input.checkbox(*args, &block); end
				def radio(name, *args, &block);    Input.radio(*args, &block);    end
				def submit(name, *args, &block);   Input.submit(*args, &block);   end
				def reset(name, *args, &block);    Input.reset(*args, &block);    end
				def file(name, *args, &block);     Input.file(*args, &block);     end
				def hidden(name, *args, &block);   Input.hidden(*args, &block);   end
				def image(name, *args, &block);    Input.image(*args, &block);    end
				def button(name, *args, &block);   new(:button, *args, &block);   end
			end
		end
	end
end
