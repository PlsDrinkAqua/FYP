#include "leds.h"
#include "uart.h"
#include "tools.h"
#include "my_stdint.h"
#define N_ORIG  89
#define N_PAD   128
#define M_PAD   (N_PAD/2 + 1)

static const double input_time[89] = {
    386, 356, 320, 307, 244, 237, 212, -267,
    -850, -1109, -967, -464, 118, 427, 485, 397,
    312, 326, 332, 310, 309, 303, 295, 293,
    279, 301, 285, 215, 169, -74, -679, -949,
    -1001, -949, -668, -153, 226, 392, 495, 511,
    479, 440, 414, 385, 404, 444, 418, 373,
    365, 385, 383, 360, 334, 252, 153, 143,
    -206, -859, -1069, -780, -460, -276, -210, -930,
    -1716, -662, 243, 241, -167, -136, 146, 269,
    307, 305, 307, 231, 85, 43, 63, 69,
    123, 127, 95, 131, 168, 150, 152, 156,
    143
};

static const uint16_t bitrev[128] = {
      0,  64,  32,  96,  16,  80,  48, 112,
      8,  72,  40, 104,  24,  88,  56, 120,
      4,  68,  36, 100,  20,  84,  52, 116,
     12,  76,  44, 108,  28,  92,  60, 124,
      2,  66,  34,  98,  18,  82,  50, 114,
     10,  74,  42, 106,  26,  90,  58, 122,
      6,  70,  38, 102,  22,  86,  54, 118,
     14,  78,  46, 110,  30,  94,  62, 126,
      1,  65,  33,  97,  17,  81,  49, 113,
      9,  73,  41, 105,  25,  89,  57, 121,
      5,  69,  37, 101,  21,  85,  53, 117,
     13,  77,  45, 109,  29,  93,  61, 125,
      3,  67,  35,  99,  19,  83,  51, 115,
     11,  75,  43, 107,  27,  91,  59, 123,
      7,  71,  39, 103,  23,  87,  55, 119,
     15,  79,  47, 111,  31,  95,  63, 127
};

static const double twiddle_real[64] = {
    1.000000000, 0.998795456, 0.995184727, 0.989176510, 0.980785280, 0.970031253, 0.956940336, 0.941544065,
    0.923879533, 0.903989293, 0.881921264, 0.857728610, 0.831469612, 0.803207531, 0.773010453, 0.740951125,
    0.707106781, 0.671558955, 0.634393284, 0.595699304, 0.555570233, 0.514102744, 0.471396737, 0.427555093,
    0.382683432, 0.336889853, 0.290284677, 0.242980180, 0.195090322, 0.146730474, 0.098017140, 0.049067674,
    0.000000000, -0.049067674, -0.098017140, -0.146730474, -0.195090322, -0.242980180, -0.290284677, -0.336889853,
    -0.382683432, -0.427555093, -0.471396737, -0.514102744, -0.555570233, -0.595699304, -0.634393284, -0.671558955,
    -0.707106781, -0.740951125, -0.773010453, -0.803207531, -0.831469612, -0.857728610, -0.881921264, -0.903989293,
    -0.923879533, -0.941544065, -0.956940336, -0.970031253, -0.980785280, -0.989176510, -0.995184727, -0.998795456
};

static const double twiddle_imag[64] = {
    -0.000000000, -0.049067674, -0.098017140, -0.146730474, -0.195090322, -0.242980180, -0.290284677, -0.336889853,
    -0.382683432, -0.427555093, -0.471396737, -0.514102744, -0.555570233, -0.595699304, -0.634393284, -0.671558955,
    -0.707106781, -0.740951125, -0.773010453, -0.803207531, -0.831469612, -0.857728610, -0.881921264, -0.903989293,
    -0.923879533, -0.941544065, -0.956940336, -0.970031253, -0.980785280, -0.989176510, -0.995184727, -0.998795456,
    -1.000000000, -0.998795456, -0.995184727, -0.989176510, -0.980785280, -0.970031253, -0.956940336, -0.941544065,
    -0.923879533, -0.903989293, -0.881921264, -0.857728610, -0.831469612, -0.803207531, -0.773010453, -0.740951125,
    -0.707106781, -0.671558955, -0.634393284, -0.595699304, -0.555570233, -0.514102744, -0.471396737, -0.427555093,
    -0.382683432, -0.336889853, -0.290284677, -0.242980180, -0.195090322, -0.146730474, -0.098017140, -0.049067674
};

// —— Precomputed, fused Min–Max–scaled SVM weights (double) ——
static const double w2[M_PAD] = {
   -1.174229e-03, -1.073418e-02, -1.818262e-04,  1.160419e-02,  5.773936e-03,
   -5.729328e-03,  3.749853e-04,  1.291006e-02,  1.646679e-02,  2.245779e-02,
    1.194814e-02,  1.235272e-02,  1.196015e-02,  6.671096e-03,  7.303838e-04,
    2.442580e-03, -2.676563e-03, -7.135418e-03,  1.065786e-02,  1.055138e-02,
    4.793684e-03,  2.179535e-03,  6.294449e-03,  1.977423e-03,  3.749153e-03,
    4.091783e-03,  8.265088e-03,  8.402915e-03,  1.335037e-02,  1.505551e-02,
    1.738370e-02,  1.642492e-02,  2.354552e-02,  6.572340e-03, -3.444605e-03,
    9.882108e-04,  1.594474e-02,  1.066821e-02,  3.980918e-02,  3.519347e-02,
    2.460549e-02,  2.761211e-02,  6.135139e-02,  1.588863e-02,  4.648122e-02,
    5.372854e-02, -3.815989e-03,  6.629171e-02,  7.750432e-02,  2.013939e-02,
    4.204697e-02,  6.194379e-02,  1.079946e-02,  1.123921e-02, -7.232866e-02,
   -1.087693e-01,  2.881493e-02, -1.283917e-02, -5.561028e-02, -5.123963e-02,
   -7.449077e-02, -4.398712e-02, -1.161510e-01, -9.575291e-02, -4.668788e-02
};

// —— Precomputed fused SVM bias (double) ——
static const double b2 = -2.426192e+00;

// ——— In-place Radix-2 FFT on separate real/imag arrays ———
static inline void fft_radix2(double real[], double imag[]) {
    // 1) bit-reverse
    int log2N = 7; // since 2^7 = 128
    for(int i = 0; i < N_PAD; i++){
        uint16_t j = bitrev[i];
        if(i < j) {
            double t = real[i]; real[i] = real[j]; real[j] = t;
            t = imag[i];      imag[i] = imag[j]; imag[j] = t;
        }
    }
    // 2) iterative butterflies
    for(int s = 1; s <= log2N; s++){
        int m = 1 << s;
        int half = m >> 1;
        int step = N_PAD >> s;
        for(int k = 0; k < N_PAD; k += m){
            for(int j = 0; j < half; j++){
                double wr = twiddle_real[j*step];
                double wi = twiddle_imag[j*step];
                int idx = k + j;
                int idx2 = idx + half;
                double xr = real[idx2];
                double xi = imag[idx2];
                // complex multiply: (xr + j xi)*(wr + j wi)
                double tr = xr*wr - xi*wi;
                double ti = xr*wi + xi*wr;
                // butterfly
                real[idx2] = real[idx] - tr;
                imag[idx2] = imag[idx] - ti;
                real[idx]   = real[idx] + tr;
                imag[idx]   = imag[idx] + ti;
            }
        }
    }
}


static double sqrta(double x) {
    if(x <= 0.0) return 0.0;
    // 把 x 的指数拿过来做初始猜
    uint64_t i = *(uint64_t*)&x;
    // 0x5FE6EB50C7B537A9 是双精度下的魔数
    i = 0x5FE6EB50C7B537A9ULL - (i >> 1);
    double r = *(double*)&i;
    // 几次牛顿迭代
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    r = 0.5*(r + x/r);
    return r;
}

int svm_predict(const double mag[M_PAD]) {
    double sum = b2;
    for(int i = 0; i < M_PAD; ++i) {
        sum += w2[i] * mag[i];
    }
    return sum >= 0.0 ? 1 : 0;
}


int main(void) {

    set_leds(1);
    uart_set_div(234);  /* 27MHz/115200 */
    uart_puts("While Loop Begins: \r\n");
    // 1) prepare arrays and zero-pad
    double real[N_PAD], imag[N_PAD];
    for(int i = 0; i < N_ORIG; i++){
        real[i] = input_time[i];
        imag[i] = 0.0;
    }
    for(int i = N_ORIG; i < N_PAD; i++){
        real[i] = imag[i] = 0.0;
    }


    //fft开始时的cycle
    uint64_t cycles;

    cycles = read_cycle64();

    // 拆高/低 32 bit，分别调用 uart_print_hex
    uart_puts("FFT: ");
    uart_print_hex((uint32_t)(cycles >> 32));  // 打印高 32bit
    uart_print_hex((uint32_t)(cycles      ));  // 打印低  32bit

    uart_puts("\r\n");

    // 2) run FFT
    fft_radix2(real, imag);
    double mag[M_PAD];

    // 3) compute normalized magnitude and print
    for(int k = 0; k < M_PAD; k++){
        double energy = real[k]*real[k] + imag[k]*imag[k];
        mag[k] = sqrta(energy) / (double)N_PAD;
    }


    cycles = read_cycle64();
    uart_puts("SVM: ");
    uart_print_hex((uint32_t)(cycles >> 32));  // 打印高 32bit
    uart_print_hex((uint32_t)(cycles      ));  // 打印低  32bit
    uart_puts("\r\n");
    int label = svm_predict(mag);
    uart_print_int(label);
    uart_puts("\r\n");

    cycles = read_cycle64();

    // 拆高/低 32 bit，分别调用 uart_print_hex
    uart_puts("Seizure detection ENDS: ");
    uart_print_hex((uint32_t)(cycles >> 32));  // 打印高 32bit
    uart_print_hex((uint32_t)(cycles      ));  // 打印低  32bit
    uart_puts("\r\n");
}
