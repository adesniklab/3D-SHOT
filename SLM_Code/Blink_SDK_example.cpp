// Blink_SDK_example.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"  // Does nothing but #include targetver.h.

#include <vector>
#include <cstdio>
#include <conio.h>
#include "Blink_SDK.h"  // Relative path to SDK header.
#include <thread>

// ------------------------- Blink_SDK_example --------------------------------
// Simple example using the Blink_SDK DLL to send a sequence of phase targets
// to a single SLM.
// The code is written with human readability as the main goal.
// The Visual Studio 2010 sample project settings assume that Blink_SDK.lib is
// in relative path ../Blink_SDK/x64/Release.
// To run the example, ensure that Blink_SDK.dll is in the same directory as
// the Blink_SDK_example.exe.
// ----------------------------------------------------------------------------


// Typedef for the container for our phase targets.
typedef std::vector<unsigned char>  uchar_vec;


// -------------------- Consume_keystrokes ------------------------------------
// Utility function to use up the keystrokes used to interrupt the display
// loop.
// ----------------------------------------------------------------------------
static void Consume_keystrokes()
{
  // Get and throw away the character(s) entered on the console.
  int k = 0;
  while ((!k) || (k == 0xE0))  // Handles arrow and function keys.
  {
    k = _getch();
  }

  return;
}


// -------------------- Generate_ramp_image -----------------------------------
// Generates 8-wide vertical ramps, with values 0 to 223, in seven steps.
// ----------------------------------------------------------------------------
static void Generate_ramp_image(const bool increasing,
                                const size_t width,
                                const size_t height,
                                uchar_vec& pixels)
{
  // This function ASSUMES that pixels.size() is at least width * height.

  unsigned char* pix = pixels.data();

  // Since 255 is "the same" as 0, go up to 7/8 of 255. Hence, divide by 8.
  const double step = 255.0 / 8.0;

  for (size_t i = 0U; i < height; ++i)    // for each row
  {
    for (size_t j = 0U; j < width; ++j)  // for each column
    {
      size_t k = j & 0x07;
      if (!increasing)
      {
        k = 7 - k;
      }
      *pix++ = static_cast<unsigned char>(static_cast<int>(k * step + 0.5));
    }
  }

  return;
}

// -------------------- Generate_stripe_image -----------------------------------
// Generates 'peroiod'-wide stripes.
// ----------------------------------------------------------------------------
static void Generate_stripe_image(const size_t period,
  const size_t width,
  const size_t height,
  uchar_vec& pixels)
{
  bool flipR = false;
  bool flipC = false;
  for (unsigned int i = 0; i < height; i++)
  {
    for (unsigned int j = 0; j < width; j++)
    {
      flipC = j % (2 * period) < period;

      pixels[i * width + j] = flipR ^ flipC ? 0 : 128;
    }
  }

  return;
}

// -------------------- Simple_loop -------------------------------------------
// This function toggles between two ramp images, calculating the Overdrive
// frame sequence on the fly.
// ----------------------------------------------------------------------------
static bool Simple_loop(const uchar_vec& img1, const uchar_vec& img2,
                        const int board_number, Blink_SDK& sdk)
{
  puts("\nSimple_loop: Press any key to exit.\n");

  bool okay      = true;
  unsigned int i = 0;
  bool wait_for_extern_trig = false;
  bool output_trig = true;
  const unsigned int timeout_ms = 5000u;

  while ((okay) && (!_kbhit()))
  {
    // Allow multiple consecutive frames of each image.
    enum { e_n_consecutive = 1 };
    unsigned int j = 0;
    const unsigned char* puc = img1.data();
    while ((okay) && (j < (2 * e_n_consecutive)))
    {
      okay = sdk.Write_image(board_number, puc, sdk.Get_image_height(board_number), wait_for_extern_trig, output_trig);
      //std::this_thread::sleep_for(std::chrono::milliseconds(100));
      if ((++j) == e_n_consecutive)
      {
        puc = img2.data();
      }
    }
    ++i;
    if (!(i % 50))
    {
      printf("Completed cycles: %u\r", i);
    }
  }

  if (okay)     // Loop terminated because of a keystroke?
  {
    Consume_keystrokes();
  }

  return okay;
}



// -------------------- main --------------------------------------------------
// Simple example using the Blink_SDK DLL to send a sequence of phase targets
// to a single 512x512 SLM.
// This code yields a console application that will loop until the user presses
// a key.
// * If no command arguments are provided, then the application toggles between
//   a blank image and a stripe pattern.
// ----------------------------------------------------------------------------
int main(const int argc, char* const argv[])
{
  bool use_trigger = false;
  if (argc > 1)
  {
     use_trigger = strtol(argv[1], 0, 10) > 0 ? true : false;
     printf("Use triggering = %s", use_trigger ? "true" : "false");
  }
  // Decide whether we will pre-calculate the overdrive frames, or calculate
  // them on the fly.
  const int board_number = 1;
  // Construct a Blink_SDK instance with Overdrive capability.
  unsigned int bits_per_pixel = 12U;
  bool         is_nematic_type = true;
  bool         RAM_write_enable = true;
  bool         use_GPU_if_available = true;

  unsigned int n_boards_found = 0U;
  bool         constructed_okay = true;

  Blink_SDK::Preset_triggering_mode(use_trigger);

  Blink_SDK sdk(bits_per_pixel, &n_boards_found,
    &constructed_okay, is_nematic_type, RAM_write_enable,
    use_GPU_if_available, 20U, 0);


  // Check that everything started up successfully.
  bool okay = constructed_okay;

  if (okay)
  {
    enum { e_n_true_frames = 5 };
    okay = sdk.Load_LUT_file(board_number, "C:\\Program Files\\Meadowlark Optics\\Blink OverDrive Plus\\LUT Files\\linear.lut");
  }

  auto pixel_height = sdk.Get_image_height(board_number);
  auto pixel_width = sdk.Get_image_width(board_number);
  // Create two vectors to hold values for two SLM images with different images.
  uchar_vec blank(pixel_height * pixel_width, 0);
  uchar_vec stripe1(pixel_height * pixel_width, 0);
  Generate_stripe_image(8, pixel_width, pixel_height, stripe1);

  if (okay)
  {
    okay = Simple_loop(stripe1, blank, board_number, sdk);
  }

  // Error reporting, if anything went wrong.
  if (!okay)
  {
    puts(sdk.Get_last_error_message());
  }
  else
  {
    sdk.SLM_power(false);
  }

  return (okay) ? EXIT_SUCCESS : EXIT_FAILURE;
}
