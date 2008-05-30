Array.prototype.empty = function() {
	return(this.length == 0);
};
Array.prototype.each = function(yield) {
	for (var i=0; i<this.length; i++) {
		yield(i, this[i]);
	};
	return(this);
};
Object.prototype.each = function(yield) {
	for (property in this) {
		if (this.hasOwnProperty(property)) {
			yield(property, this[property]);
		}
	};
	return(this);
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
		"not_empty": function(value) {
			return(value.length > 0);
		},
		"is_email": function(value) {
			return(/\A[\x21-\xff]+@[\x21-\xff]+\.[A-Za-z]{2,}\z/.test(value));
		},
		"is_url": function(value) {
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
	}
};