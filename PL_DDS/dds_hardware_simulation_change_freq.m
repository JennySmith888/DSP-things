% -----------------------------------------------------------------------------
%
%    File Name:             dds_hardware_simulation_change_freq.m
%    Type:                  Matlab Script
%    Author:                J. Smith
%    Updated:               Jan 2025
% 
%    Description:           Simulate AMD / Xilinx DDS behavior with 
%                           changing phase increment.
%
%    Inputs:                total_time    - total amount of simulation
%                                           input data to generate. Should
%                                           be longer than sim time.
%                           f_clk         - DDS clock
%                           M             - DDS rasterized mode modulous
%                                           allowed values [1:16384]
%                           p_inc1        - initial phase increment
%                                         - allowed values [1:16384]
%                           p_inc2        - second phase increment allowed
%                                           values [1:16384]
%                           index_change - Sample number where the input
%                                          phase increment changes from
%                                          p_inc1 to p_inc2
%
%
%    Notes: Meant to be run with 'dds_model.slx' simulation. See
%           'dds_hardware_simulation.m' for more details.
%                           
% -----------------------------------------------------------------------------
%% INPUT PARAMETERS
total_time = 128e6;
f_clk = 128e6; % DDS clk [Hz]
M = 16384; % rasterized mode modulous [1:16384]
p_inc1 = 2^9; % muliplier on freq res to produce [1:16384]
p_inc2 = 2^12;
index_change = 1000;
f_out1 = p_inc1*(f_clk/M);
f_out2 = p_inc2*(f_clk/M);
%% COMPUTE MODEL INPUTS %%
sim_time = [1:total_time]';
data_tready=[sim_time ones(total_time,1)];
phase_tready=[sim_time ones(total_time,1)];
config_tvalid=[sim_time ones(total_time,1)];
config_tdata_pinc=[sim_time (p_inc1/2^14)*ones(total_time,1)];
config_tdata_pinc(index_change:end,2)=(p_inc2/2^14)*ones(total_time-index_change+1,1);

%% RUN SIMULATION %%
out = sim('dds_model.slx', 168000);

%% PROCESS MODEL OUTPUTS %%
config_tready = out.config_tready.Data;
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
sgtitle(sprintf('DDS Hardware Simulation %d MHz and %d MHz', f_out1*1e-6, f_out2*1e-6))
sample_start = index_change-60;
sample_stop = index_change+60;
time_x = [sample_start:sample_stop];
plot(time_x,cosine_data(sample_start:sample_stop))
hold on
plot(time_x, sine_data(sample_start:sample_stop))
plot(index_change,sine_data(index_change),'o',...
    'LineWidth', 3,...
    'MarkerSize',7,...
    'MarkerEdgeColor',[0.97,0.71,0.05])
plot(index_change,cosine_data(index_change),'o',...
    'LineWidth', 3,...
    'MarkerSize',7,...
    'MarkerEdgeColor',[0.97,0.71,0.05])
legend('cosine', 'sine', 'index change')
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