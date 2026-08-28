#if !defined BLOOM_SETTINGS_FILE
#define BLOOM_SETTINGS_FILE

#define BLOOM
#define BLOOM_STRENGTH 0.12 //[0.027 0.036 0.045 0.054 0.063 0.072 0.081 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.21 0.23 0.25 0.28 0.32 10.00]

#define BLOOM_FOG

#if defined END || !defined BLOOM
    #undef BLOOM_FOG
#endif

#endif
