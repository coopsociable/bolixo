#ifdef INSTRUMENT
	#ifdef INSTRUMENT_EXTERN
		extern FILE *f_instrument;
	#else
		#ifdef INSTRUMENT_DONOTOPEN
			FILE *f_instrument = NULL;
		#else
			FILE *f_instrument = fopen ("/tmp/instrument.log","a");
		#endif
	#endif
	inline void add_to_instrument (const char *s)
	{
		if (f_instrument != NULL) fprintf (f_instrument,"# %s\n",s);
	}
	inline void open_instrument_file(PARAM_STRING fname)
	{
		f_instrument = fopen (fname.ptr,"a");
		if (f_instrument == NULL){
			tlmp_error ("Can't open instrument file %s (%s)\n",fname.ptr,strerror(errno));
		}
	}
	inline void open_instrument_file()
	{
		open_instrument_file("/tmp/instrument.log");
	}
	inline void toggle_instrument_file (bool on, PARAM_STRING fname)
	{
		if (on){
			if (f_instrument==NULL){
				open_instrument_file (fname);
			}
		}else{
			if (f_instrument != NULL){
				fclose (f_instrument);
				f_instrument = NULL;
			}
		}
	}
	inline void toggle_instrument_file (bool on)
	{
		toggle_instrument_file (on,"/tmp/instrument.log");
	}
	inline void instrument_status (std::vector<std::string> &tb)
	{
		tb.push_back(string_f("instrument: %s", f_instrument != NULL ? "on" : "disable"));
		if (f_instrument != NULL) fflush (f_instrument);
	}
#else
	extern FILE *f_instrument;
	inline void add_to_instrument(const char *){}
	inline void open_instrument_file(PARAM_STRING){}
	inline void open_instrument_file(){}
	inline void toggle_instrument_file (bool on, PARAM_STRING fname){}
	inline void toggle_instrument_file (bool on){}
	inline void instrument_status (std::vector<std::string> &tb)
	{
		tb.push_back("instrument: off");
	}
#endif
