controller 'Foo' do
	has_form :name do
		method :post
		prevent_multipost
		sessionized
		
		with_fields do
			input_text :firstname
			defaults_to ''
			falls_back_to :userinput
			validate String, :min => 3, :max => 20, :matching => /regex/
		end
	end
	
	def initialize
		# a form can be available?, valid?, erroneous?, unavailable?
		if @form[:name].available? then
			# a field has a value, an original_value, a default_value and a fallback_value
			if @form[:name][:firstname].valid? then
				...
			end
			
		end
	end
end