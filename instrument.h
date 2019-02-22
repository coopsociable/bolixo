#ifdef INSTRUMENT
	#ifdef INSTRUMENT_DONOTOPEN
		FILE *f_instrument = NULL;
	#else
		FILE *f_instrument = fopen ("/tmp/instrument.log","a");
	#endif
#else
	extern FILE *f_instrument;
#endif
