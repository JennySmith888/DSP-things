% -----------------------------------------------------------------------------
%
%    File Name:             dds_hardware_simulation.m
%    Type:                  Matlab Script
%    Author:                J. Smith
%    Updated:               Jan 2025
% 
%    Description:           Simulate AMD / Xilinx DDS behavior.
%
%    Inputs:                total_time    - total amount of simulation
%                                           input data to generate. Should
%                                           be longer than sim time.
%                           f_clk         - DDS clock.
%                           M             - DDS rasterized mode modulous
%                                           allowed values [1:16384].
%                           p_inc         - phase increment allowed values 
%                                           [1:16384].
%
%
%    Notes: Meant to be run with 'dds_model.slx' simulation. DDS operates 
%           in rasterized mode meaning it will produce integer multiples of
%           f_clk/M. p_inc is the integer multiplier and can take on values
%           [1:16384] or 2^0 to 2^14. 14-bits is required for the phase 
%           resolution and it probably makes sense to use this or 16-bits
%           for the output width.
%                           
% -----------------------------------------------------------------------------
%% INPUT PARAMETERS
total_time = 128e6;
f_clk = 128e6; % DDS clk [Hz]
M = 16384; % rasterized mode modulous [1:16384]
p_inc = 15321;%2^0; % muliplier on freq res to produce [1:16384]
p_inc_14_14 = fi(p_inc/2^14,0,14,14);
f_out = p_inc*(f_clk/M);

%% COMPUTE MODEL INPUTS%%
sim_time = [1:total_time]';
data_tready=[sim_time ones(total_time,1)];
phase_tready=[sim_time ones(total_time,1)];
config_tvalid=[sim_time ones(total_time,1)];
config_tdata_pinc=[sim_time (p_inc/2^14)*ones(total_time,1)];


%% RUN SIMULATION %%
out = sim('dds_model.slx', 168000);

%% PROCESS MODEL OUTPUTS %%
data_valid = out.data_tvalid.Data;
p_inc_out = out.converted_pinc.Data(1); % this should match p_inc_14_14;

% compute latency
data_latency = find(data_valid~=0, 1, 'first');
fprintf('Data Latency: %d clocks \n', data_latency);

% process simulation outputs
cosine_data = out.data_tdata_cosine.Data(data_latency:end);
sine_data = out.data_tdata_sine.Data(data_latency:end);

% plot data
subplot(2,1,1)
sgtitle(sprintf('DDS Hardware Simulation %d MHz', f_out*1e-6))
samples = 167989;%60;
plot(cosine_data(1:samples))
hold on
plot(sine_data(1:samples))
legend('cosine', 'sine')
xlabel(sprintf('Sample (every %.4f ns)', (1/f_clk)*1e9))
ylabel('Magnitude')
title('Time Domain')

subplot(2,1,2)
fft_data = 20*log10(abs(fftshift(fft(cosine_data+1j*sine_data))));
freq_ax = linspace(-f_clk/2, f_clk/2, length(sine_data));
plot(freq_ax*1e-6, fft_data-max(fft_data));
xlabel('Frequency (MHz)')
ylabel('Power (dB)')
title('Frequency Domain')