Proto({

	~params = List();

	//List storage
	//Go through all keys in params
	//and update them with value from obj if value is not nil
	~setParams = { |obj|
		~params.do { |v, i|
			obj[i] !? { |newVal|
				~params[i].value = newVal;
				currentEnvironment.changed(\index, i, newVal);
			}
		}
	};

	~getParams = { |usage|
		~params.collect(_.value)
	};

	~get = { |index|
		~params[index].value;
	};

	~getInput = { |index|
		~params[index] !? ( _.input );
	};

	~set = { |index, value|
		~params[index].value = value;
		currentEnvironment.changed(\index, index, value);
	};

	~setInput = { |index, input|
		~params[index].input = input;
	};

});