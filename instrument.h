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
#else
	extern FILE *f_instrument;
	inline void add_to_instrument(const char *){}
#endif
