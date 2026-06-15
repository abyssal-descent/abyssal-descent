#ifndef CLOUD_SETTINGS_FILE
#define CLOUD_SETTINGS_FILE

#define CLOUD_CLOSED_AREA_CHECK
#define CLOUD_R 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
#define CLOUD_G 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
#define CLOUD_B 100 //[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 220 240 260 280 300]
#define CLOUD_UNBOUND_AMOUNT 1.00 //[0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00 1.02 1.04 1.06 1.08 1.10 1.12 1.14 1.16 1.18 1.20 1.22 1.24 1.26 1.28 1.30 1.32 1.34 1.36 1.38 1.40 1.42 1.44 1.46 1.48 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00 2.10 2.20 2.30 2.40 2.50 2.60 2.70 2.80 2.90 3.00]
#define CLOUD_UNBOUND_RAIN_ADD 0.40 //[0.00 0.05 0.06 0.07 0.08 0.09 0.10 0.12 0.14 0.16 0.18 0.22 0.26 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50]


// Euphoria Patches Settings


#define CLOUD_STRETCH 1.0 //[0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define CLOUD_DIRECTION 1 //[1 2]
//#define CLOUD_MINECRAFT_TEXTURE
#define CLOUD_ROUNDNESS 0.125 //[0.025 0.05 0.125 0.2]
#define RAINBOW_CLOUD 0 //[0 1 2 3 4 5 6 7 8 8 10]
#if RAINBOW_CLOUD == 0
const float rainbowCloudDistribution = 0.0;
#elif RAINBOW_CLOUD == 1
const float rainbowCloudDistribution = 1.0;
#elif RAINBOW_CLOUD == 2
const float rainbowCloudDistribution = 2.0;
#elif RAINBOW_CLOUD == 3
const float rainbowCloudDistribution = 3.0;
#elif RAINBOW_CLOUD == 4
const float rainbowCloudDistribution = 4.0;
#elif RAINBOW_CLOUD == 5
const float rainbowCloudDistribution = 5.0;
#elif RAINBOW_CLOUD ==6
const float rainbowCloudDistribution = 6.0;
#elif RAINBOW_CLOUD == 7
const float rainbowCloudDistribution = 7.0;
#elif RAINBOW_CLOUD == 8
const float rainbowCloudDistribution = 8.0;
#elif RAINBOW_CLOUD == 9
const float rainbowCloudDistribution = 9.0;
#elif RAINBOW_CLOUD == 10
const float rainbowCloudDistribution = 10.0;
#endif
#define CLOUD_RENDER_DISTANCE 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 7.0]

//#define DH_CLOUD_TWEAK_OVERRIDE // internal hidden DH setting

#define CLOUD_UNBOUND_LAYER2_HEIGHT 1.0 //[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define CLOUD_UNBOUND_LAYER2_SIZE 5 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define CLOUD_UNBOUND_LAYER2_AMOUNT 2.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define CLOUD_LAYER2_SPEED_MULT 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0]

#endif