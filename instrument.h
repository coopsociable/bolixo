#ifdef INSTRUMENT
	#ifdef INSTRUMENT_DONOTOPEN
		FILE *f_instrument = NULL;
	#else
		FILE *f_instrument = fopen ("/tmp/instrument.log","a");
	#endif
	void add_to_instrument (const char *s)
	{
		if (f_instrument != NULL) fprintf (f_instrument,"# %s\n",s);
	}
#else
	extern FILE *f_instrument;
	inline add_to_instrument(const char *){}
#endif
