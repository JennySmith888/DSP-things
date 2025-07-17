# PL-DDS

This folder contains MATLAB simulations using MATLAB R2021a with Vivado 2023.1. 

## Open and Run the Models

### Tool Setup
Make sure you have MATLAB 2021a installed and install Vivado 2023.1 with the Model Composer libraries.

Please note these tools have specific compatible OS's. For this project, I used a Docker image based on Ubuntu 20.04. Reach out to me for more details on this.

Source the path to Vivado 2023.1: `source <path/to/vivado/2023.1/settings64.sh>`.
Make sure your Matlab license is correctly configured--refer to Mathworks documentation.
Make sure the right version of MATLAB is first on your $PATH.

Launch the tool using: `model_composer`.

## The Models
### DDS-Only
`dds_software.m` Start here as a reminder how the complex multiply results in a frequency shift.

`dds_hardware_simulation.m` This file will run the `dds_model.slx` to demonstrate the xilinx DDS configuration and operation.

`dds_hardware_simulation_change_freq.m` Runs the same `.slx` model but this time changes the phase increment part way through to show how the DDS behaves when the programmed frequency changes.

### DDS + FIR
`multirate_filter_design.m` contains the interpolating filter coefficients. Use MATLAB Filter Designer to design a new multirate filter if needed. Remember the number of cofficients corresponds to the interpolation factor.

`interpolated_fir_hardware_simulation.m`: Need to run `dds_hardware_simulation` first to generate the data from `dds_model.slx`. This script feeds the data into `interpolated_fir_model.slx` and visualizes the output.
