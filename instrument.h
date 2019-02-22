#ifdef INSTRUMENT_DONOTOPEN
	FILE *f_instrument = NULL;
#else
	#ifdef INSTRUMENT
		FILE *f_instrument = fopen ("/tmp/instrument.log","a");
	#else
		extern FILE *f_instrument;
	#endif
#endif
