#include<stdio.h>
#include<stdlib.h>

#define N 1                         /// order of the filter
#define NTm1 (N)                    /// number of coefficients minus one (equal to the order)
#define NB 14                       /// number of bits
#define SHAMT 21                    /// shift amount (shift amount 21 can also be used but gives THD = -30.55 dB)

const int bi0 = 3447;               /// coefficient b0
const int bi[NTm1] = {3447, 3447};  /// b array, obtained from MATLAB design
const int ai[NTm1] = {-1298, 8192};  /// a array, obtained from MATLAB design

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x)
{
  static int counter = 0;
  static int sw[NTm1]; /// w shift register
  static int first_run = 0; /// for cleaning the shift register
  int i; /// index
  int w; /// intermediate value (w)
  int y; /// output sample
  int fb, ff; /// feed-back and feed-forward results

  /// clean the buffer
  if (first_run == 0)
  {
    first_run = 1;
    for (i = 0; i < NTm1; i++)
      sw[i] = 0;
  }

  /// compute feed-back and feed-forward
  fb = 0;
  ff = 0;
  for (i = 0; i < NTm1; i++)
  {
    fb -= ((sw[i] * ai[i]) >> SHAMT) << (SHAMT - NB + 1);
    ff += ((sw[i] * bi[i]) >> SHAMT) << (SHAMT - NB + 1);
    printf("Sample: %d, x: %d, fb: %d, ff: %d, ", counter, x, fb, ff);
  }

  /// compute intermediate value (w) and output sample
  w = x + fb;
  y = ((w * bi0) >> SHAMT) << (SHAMT - NB + 1);
  y += ff;

  sw[0] = w;

  counter++;
  printf("w: %d, sw[0]: %d, sw[1]: %d, y: %d\n", w, sw[0], sw[1], y);
  return y;
}

int main(int argc, char **argv)
{
  FILE *fp_in;
  FILE *fp_out;

  int x;
  int y;

  /// check the command line
  if (argc != 3)
  {
    printf("Use: %s <input_file> <output_file>\n", argv[0]);
    exit(1);
  }

  /// open files
  fp_in = fopen(argv[1], "r");
  if (fp_in == NULL)
  {
    printf("Error: cannot open %s\n", argv[1]);
    exit(2);
  }
  fp_out = fopen(argv[2], "w");

  /// check shift amount
  if (SHAMT < ((NB)-1))
  {
    printf("Error shift amount must be at least nbit-1\n");
    exit(3);
  }

  /// get samples and apply filter
  fscanf(fp_in, "%d", &x);
  do
  {
    y = myfilter(x);
    fprintf(fp_out, "%d\n", y);
    fscanf(fp_in, "%d", &x);
  } while (!feof(fp_in));

  fclose(fp_in);
  fclose(fp_out);

  return 0;
}
