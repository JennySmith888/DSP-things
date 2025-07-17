% -----------------------------------------------------------------------------
%
%    File Name:             fir_hardware_simulation.m
%    Type:                  Matlab Script
%    Author:                J. Smith
%    Updated:               Feb 2025
% 
%    Description:           Simulate AMD / Xilinx FIR behavior.
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
%    Notes: Meant to be run with 'interpolated_fir_model.slx' simulation.
%           the input data is meant to be generated from 'dds_model.m'. 
%           The dds model creates 128 MHz sine and cosine waveforms. This
%           simulation DDS operates 
%           in rasterized mode meaning it will produce integer multiples of
%           f_clk/M. p_inc is the integer multiplier and can take on values
%           [1:16384] or 2^0 to 2^14. 14-bits is required for the phase 
%           resolution and it probably makes sense to use this or 16-bits
%           for the output width.
%                           
% -----------------------------------------------------------------------------
%% INPUT PARAMETERS
% run 'dds_hardware_simulation.m' to generate sine/cosine data 
clearvars -except cosine_data sine_data f_out
total_time = 671956;
fs = 4.096e9; % final sample rate [GHz]

%% COMPUTE MODEL INPUTS%%
% "upsample" cos/sin data by 4 to mimic clock conversion from 128 MHz
% to 512 MHz. Will effectivly repeat each sample 4x.
cdc_mat = zeros(4,length(cosine_data));
sine_data_fast = reshape(sine_data.'+cdc_mat, [], 1);
cosine_data_fast = reshape(cosine_data.'+cdc_mat, [], 1);

sim_time = [1:total_time]';
data_tvalid=[sim_time ones(total_time,1)];
data_tdata_path1=[sim_time cosine_data_fast];
data_tdata_path2=[sim_time sine_data_fast];

% Multi-Rate Filter
filt = multirate_filter_design;
filt_coef = filt.Numerator;

%data_tdata_path1=[sim_time ones(1,length(cos_padded)).'];
%data_tdata_path2=[sim_time ones(1,length(cos_padded)).'];

%% RUN SIMULATION %%
%out = sim('interpolated_fir_model.slx', total_time);

%% PROCESS MODEL OUTPUTS %%
data_valid = out.tvalid.Data;

% compute latency
data_latency = find(data_valid~=0, 1, 'first');
fprintf('Data Latency: %d clocks \n', data_latency);

% process simulation outputs
samp0i = out.data_tdata_vec0_path0.Data(data_latency:end);
samp0q = out.data_tdata_vec0_path1.Data(data_latency:end);
samp1i = out.data_tdata_vec1_path0.Data(data_latency:end);
samp1q = out.data_tdata_vec1_path1.Data(data_latency:end);
samp2i = out.data_tdata_vec2_path0.Data(data_latency:end);
samp2q = out.data_tdata_vec2_path1.Data(data_latency:end);
samp3i = out.data_tdata_vec3_path0.Data(data_latency:end);
samp3q = out.data_tdata_vec3_path1.Data(data_latency:end);
samp4i = out.data_tdata_vec4_path0.Data(data_latency:end);
samp4q = out.data_tdata_vec4_path1.Data(data_latency:end);
samp5i = out.data_tdata_vec5_path0.Data(data_latency:end);
samp5q = out.data_tdata_vec5_path1.Data(data_latency:end);
samp6i = out.data_tdata_vec6_path0.Data(data_latency:end);
samp6q = out.data_tdata_vec6_path1.Data(data_latency:end);
samp7i = out.data_tdata_vec7_path0.Data(data_latency:end);
samp7q = out.data_tdata_vec7_path1.Data(data_latency:end);


i_serial_data = reshape([samp0i samp1i samp2i samp3i samp4i samp5i samp6i samp7i].',1,[]); 
q_serial_data = reshape([samp0q samp1q samp2q samp3q samp4q samp5q samp6q samp7q].',1,[]);
clear samp*

% plot data
subplot(2,1,1)
sgtitle(sprintf('Interpolated FIR Hardware Simulation %d MHz', f_out*1e-6))
samples = length(q_serial_data);%3520;
plot(i_serial_data(1:samples))
hold on
plot(q_serial_data(1:samples))
legend('cosine', 'sine')
xlabel('Sample (512 MHz)')
ylabel('Magnitude')
title('Time Domain')

subplot(2,1,2)
fft_data = 20*log10(abs(fftshift(fft(i_serial_data+1j*q_serial_data))));
freq_ax = linspace(-fs/2, fs/2, length(i_serial_data));
plot(freq_ax*1e-6, fft_data-max(fft_data));
xlabel('Frequency (MHz)')
ylabel('Power (dB)')
title('Frequency Domain')


%a = [1 zeros(1,31) 1 zeros(1,31) 1 zeros(1,31) 1 zeros(1,31) 1 zeros(1,31)];
%c = conv(a,Num);



a = 0;
b = 15;

for i=0:15
    [b+(16*i) a+16*i]
end
