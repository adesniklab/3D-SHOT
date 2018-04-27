//
//:  Blink_SDK_C_wrapper for programming languages that can interface with DLLs
//
//   (c) Copyright Boulder Nonlinear Systems 2014 - 2014, All Rights Reserved.
//   (c) Copyright Meadowlark Optics 2015-2017, All Rights Reserved.

#ifndef BLINK_SDK_CWRAPPER_H_
#define BLINK_SDK_CWRAPPER_H_

#ifdef SDK_WRAPPER_EXPORTS
#define BLINK_WRAPPER_API __declspec(dllexport)
#else
#define BLINK_WRAPPER_API
#endif

#ifdef __cplusplus
extern "C" { /* using a C++ compiler */
#endif

  //typedef struct Blink_SDK Blink_SDK; /* make the class opaque to the wrapper */

  BLINK_WRAPPER_API void* Create_SDK(unsigned int SLM_bit_depth,
                                          unsigned int* n_boards_found,
                                          int *constructed_ok,
                                          int is_nematic_type,
                                          int RAM_write_enable,
                                          int use_GPU_if_available,
                                          int max_transient_frames,
                                          char* static_regional_lut_file);

  BLINK_WRAPPER_API void Delete_SDK(void *sdk);

  BLINK_WRAPPER_API
  int Is_slm_transient_constructed(void *sdk);

  BLINK_WRAPPER_API
  int Write_overdrive_image(void *sdk, int board,
                             unsigned char* target_phase,
                             int wait_for_trigger,
                             int external_pulse,
							 unsigned int trigger_timeout_ms);

  BLINK_WRAPPER_API
  int Calculate_transient_frames(void *sdk, unsigned char* target_phase,
                                  unsigned int* byte_count);

  BLINK_WRAPPER_API
  int Retrieve_transient_frames(void *sdk, unsigned char* frame_buffer);

  BLINK_WRAPPER_API
  int Write_transient_frames(void *sdk, int board,
                              unsigned char* frame_buffer,
                              int wait_for_trigger,
                              int external_puls,
							  unsigned int trigger_timeout_ms);

  BLINK_WRAPPER_API
  int Read_transient_buffer_size(void *sdk, char*   filename,
                                  unsigned int* byte_count);

  BLINK_WRAPPER_API
  int Read_transient_buffer(void *sdk,
                             char*    filename,
                             unsigned int   byte_count,
                             unsigned char* frame_buffer);

  BLINK_WRAPPER_API
  int Save_transient_frames(void *sdk,
                             char*          filename,
                             unsigned char* frame_buffer);

  BLINK_WRAPPER_API
  const char* Get_last_error_message(void *sdk);

  BLINK_WRAPPER_API
  int Load_overdrive_LUT_file(void *sdk, char* static_regional_lut_file);

  BLINK_WRAPPER_API
  int Load_linear_LUT(void *sdk, int board);

  BLINK_WRAPPER_API
  const char* Get_version_info(void *sdk);

  BLINK_WRAPPER_API
  void SLM_power(void *sdk, int power_state);

  // ----------------------------------------------------------------------------
  //  Write_image
  // ----------------------------------------------------------------------------
  BLINK_WRAPPER_API
  int Write_image(void *sdk, 
                   int board, 
                   unsigned char* image, 
                   unsigned int image_size,
                   int wait_for_trigger,
                   int external_pulse,
				   unsigned int trigger_timeout_ms);

  // ----------------------------------------------------------------------------
  //  Load_LUT_file
  // ----------------------------------------------------------------------------
  BLINK_WRAPPER_API int Load_LUT_file(void *sdk, int board, char* LUT_file);

  // ----------------------------------------------------------------------------
  //  Compute_TF
  // ----------------------------------------------------------------------------
  BLINK_WRAPPER_API int Compute_TF(void *sdk, float frame_rate);

  // ----------------------------------------------------------------------------
  //  Set_true_frames
  // ----------------------------------------------------------------------------
  BLINK_WRAPPER_API void Set_true_frames(void *sdk, int true_frames);

  BLINK_WRAPPER_API void Stop_sequence(void *sdk);

#ifdef __cplusplus
}
#endif


#endif // BLINK_SDK_CWRAPPER_H_