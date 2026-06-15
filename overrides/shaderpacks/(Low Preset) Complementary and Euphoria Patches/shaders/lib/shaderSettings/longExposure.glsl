#ifndef LONG_EXPOSURE_SETTINGS_FILE
#define LONG_EXPOSURE_SETTINGS_FILE

#define LONG_EXPOSURE 0 //[0 1 2] // when GUI is hidden and not moving screenshot mode is on

#ifdef RENKO_CUT
    #undef LONG_EXPOSURE
    #define LONG_EXPOSURE 0 // disable long exposure when Renko's cut is enabled
#endif

#endif
