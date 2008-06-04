function Field(form, name, description) {
	var field          = this;
	this._form         = form;
	this._name         = name;
	this._node         = $('[@name="'+form.name()+'.'+name+'"]');
	this._expects      = description.expects;
	this._validates_if = description.validates_if;
	this._value        = null;
	this._special      = new Array();
	this._required     = !(description.optional || description.required === false);
	this._valid        = !this._required;

	this.form          = function() { return(this._form); };
	this.name          = function() { return(this._name); };
	this.errors        = function() { return(this._errors); };
	this.node          = function() { return(this._node); };
	this.expects       = function() { return(this._expects); };
	this.validates_if  = function() { return(this._validates_if); };
	this.value         = function() { return(this._value); };
	this.valid         = function() {	return(this._valid); };
	this.erroneous     = function() {	return(!this._valid); };
	this.required      = function() { return(this._required); };
	this._on_reset     = description.on_reset;
	this._on_erroneous = description.on_erroneous;
	this._on_valid     = description.on_valid;
	this._on_missing   = description.on_missing;
	this.on_reset      = function() {
		if (this._on_reset) { this._on_reset(); };
	};
	this.on_valid      = function() {
		this.on_reset();
		if (this._on_valid) { this._on_valid(); };
	};
	this.on_erroneous  = function() {
		this.on_reset();
		if (this._on_erroneous) { this._on_erroneous(); };
	};
	this.on_missing    = function() {
		this.on_reset();
		if (this._on_missing) { this._on_missing(); };
	};
	if (description.confirms) {
		this._special[this._special.length] = {
			test: 'confirm',
			args: description.confirms
		};
	};

	this.empty         = function() {
		return(!this._value);
	};
	this.adapt         = function() {
		this._value = Adaptors[this._expects](this._value);
		return true;
	};
	this.validate      = function() {
		var valid = true;
		if (this._required || this._value) {
			for (v in this._validates_if) {
				if (this._validates_if.hasOwnProperty(v)) {
					validator = Validators[this._expects][v];
					arg       = this._validates_if[v];
					if (!validator) { throw("No validator "+v+" exists for "+this._expects) };
					if (!validator(this._value, arg)) {
						valid = false;
						break;
					};
				};
			};
			for (i=0; i<this._special.length; i++) {
				test = this._special[i].test;
				args = this._special[i].args;
				if (test == 'confirm') {
					if (this._form.field(args).value() != this._value) {
						valid = false;
						break;
					};
				};
			};
		};
		this._valid = valid;
	};
	this.set_value     = function(value) { this._value = value; };
	
	var tagname        = this._node.get(0).tagName.toLowerCase();
	if (tagname == 'input') {
		var type = this._node.attr("type").toLowerCase();
		if (type == 'text' || type == 'password' || type == 'hidden') {
			this.submit_value = function() {
				return(this._node.attr("value"));
			};
		} else if (type == 'checkbox') {
			this.submit_value = function() {
				return(this._node.attr("checked") && this._node.attr("value"));
			};
		} else if (type == 'radio') {
			this.submit_value = function() {
				return(this._node.val());
			};
		};
	} else if (tagname == 'textarea') {
		this.submit_value = function() {
			return(this._node.val());
		};
	} else if (tagname == 'select') {
		this.submit_value = function() {
			return(this._node.val());
		};
	} else if (tagname == 'button') {
		this.submit_value = function() {
			return(this._node.val());
		};
	} else {
		this.submit_value = function() {
			return(this._node.val());
		};
	};

	this._node.bind('change', function() {
		field.set_value(field.submit_value());
		if (!field.required() && (!field.value() || field.value() == "")) {
			field.on_reset();
			return;
		};
		field.adapt();
		field.validate();
		if (field.valid()) {
			field.on_valid();
		} else if (field.erroneous()) {
			field.on_erroneous();
		};
	});
}

function Form(name, description) {
	var form        = this;

	this._node      = $('form[@name="'+name+'"]');
	this._name      = name;
	this._fields    = new Array()
	this._valid     = false;

	this.name       = function() { return(this._name); };
	this.fields     = function() { return(this._fields); };
	this.errors     = function() { return(this._errors); };
	this.valid      = function() { return(this._valid); };
	this.erroneous  = function() { return(!this._valid); };

	this.field      = function(name) { return(this._fields[name]); };
	this.validate   = function() {
		var valid = true;
		for (field in this._fields) {
			if (!this._fields.hasOwnProperty(field)) { continue; };
			try {
				field = this._fields[field];
				field.validate();
				if (!field.valid()) {
					valid = false;
					break;
				};
			} catch(e) {
				alert("Error validating "+field.name()+"\n"+e);
			};
		};
		this._valid = valid;
	};
	
	this._node.bind('submit', function() {
		try {
			form.validate();
			if (form.valid()) {
				alert("form is valid");
				return true;
			} else {
				fields = form.fields();
				for (name in fields) {
					try {
						field = form.field(name);
						if (field.empty() && field.required()) {
							if (field.on_missing) {
								field.on_missing();
							};
						};
					} catch(e) {
						alert("Error processing "+field.name()+"\n"+e);
					};
				};
				alert("Please correct fields marked erroneous (red) and fill in required fields (yellow).");
				return false;
			}
		} catch(e) {
			alert(e);
			return false;
		}
	});

	if (description.with_fields) {
		fields       = description.with_fields;
		on_erroneous = description.on_erroneous;
		on_missing   = description.on_missing;
		on_valid     = description.on_valid;
		on_reset     = description.on_reset;
		for (name in fields) {
			desc = fields[name]
			if (!desc.on_erroneous && on_erroneous) {
				desc.on_erroneous = on_erroneous;
			};
			if (!desc.on_missing && on_missing) {
				desc.on_missing = on_missing;
			};
			if (!desc.on_valid && on_valid) {
				desc.on_valid = on_valid;
			};
			if (!desc.on_reset && on_reset) {
				desc.on_reset = on_reset;
			};
			form._fields[name] = new Field(form, name, fields[name]);
		};
	};
};

Adaptors = {
	"String":  function(value) { return(value); },
	"Integer": function(value) { return(parseInt(value)); },
	"Float":   function(value) { return(parseFloat(value)); }
};

Validators = {
	"String": {
		"min": function(value, min) {
			return(value.length >= min);
		},
		"min_exclusive": function(value, min) {
			return(value.length > min);
		},
		"max": function(value, max) {
			return(value.length <= max);
		},
		"max_exclusive": function(value, max) {
			return(value.length < max);
		},
		"not_empty": function(value, arg) {
			return(value.length > 0);
		},
		"is_email": function(value, arg) {
			return(/\A[\x21-\xff]+@[\x21-\xff]+\.[A-Za-z]{2,}\z/.test(value));
		},
		"is_url": function(value, arg) {
			return(false);
		},
		"match": function(value, regexp) {
			return(regexp.test(value));
		},
		"match_not": function(value, regexp) {
			return(!regexp.test(value));
		},
		"begin_of_one_of": function(value, choices) {
			return(false);
		},
		"insensitive_begin_of_one_of": function(value, choices) {
			return(false);
		},
		"one_of": function(value, choices) {
			return(false);
		},
		"none_of": function(value, choices) {
			return(false);
		}
	},
	"Integer": {
		"min": function(value, min) {
			return(value >= min);
		},
		"min_exclusive": function(value, min) {
			return(value > min);
		},
		"max": function(value, max) {
			return(value <= max);
		},
		"max_exclusive": function(value, max) {
			return(value < max);
		},
		"natural": function(value, arg) {
			return(value >= 0);
		},
		"positive": function(value, arg) {
			return(value > 0);
		},
		"negative": function(value, arg) {
			return(value >= 0);
		}
	},
	"Float": {
		"min": function(value, min) {
			return(value >= min);
		},
		"min_exclusive": function(value, min) {
			return(value > min);
		},
		"max": function(value, max) {
			return(value <= max);
		},
		"max_exclusive": function(value, max) {
			return(value < max);
		},
		"natural": function(value, arg) {
			return(value >= 0);
		},
		"positive": function(value, arg) {
			return(value > 0);
		},
		"negative": function(value, arg) {
			return(value >= 0);
		}
	}
};
