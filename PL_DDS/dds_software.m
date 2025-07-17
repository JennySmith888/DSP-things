% -----------------------------------------------------------------------------
%
%    File Name:             dds_software.m
%    Type:                  Matlab Script
%    Author:                J. Smith
%    Updated:               Jan 2025
% 
%    Description:           Basic complex multiply simulation to
%                           understand direct-digital mixing basics.
%
%    Inputs:                fs    - Sampling frequency
%                           NFFT  - Number of points in analysis FFT
%                           N     - Number of total samples
%
%    Notes:
%                           
% -----------------------------------------------------------------------------
%% GENERATE SINE WAVE %%

fs   = 4096e6;             % sampling frequency [Hz]
NFFT = 4096;               % analysis FFT size
N    = 2*NFFT;             % length of time vector
t    = (1:N)/fs;           % time vector [sec]

a_sig_1 = 1;               % tone amplitude
f_sig_1 = (100)*1e6;       % tone frequency
%snr = 90;                  % signal-to-noise ratio
%a_noise = 10^((20*log10(a_sig_1/sqrt(2)) - snr)/10);
%in_noise = sqrt(a_noise)*randn(1,N);

% complex data
in_complex = a_sig_1*exp(1i*2*pi*f_sig_1*t);

%% PLOT INPUT DATA %%
x_in         = in_complex(1:NFFT);
in_spect_log = fftshift(20*log10(abs(fft(x_in)))); % log scale
in_spect_log = in_spect_log - max(in_spect_log); % normalize log scale
freq_ax      = ((-NFFT/2:(NFFT/2)-1)/NFFT)*fs;
figure(1)
sgtitle(sprintf('Input %d MHz Waveform', f_sig_1*1e-6))
subplot(2,1,1);
plot(t(1:500)*10^6,real(in_complex(1:500)))
ylabel('Real Signal')
xlabel('Time (microseconds)')
title('Time Domain')
subplot(2,1,2);
plot(freq_ax/1e6,in_spect_log(1:NFFT))
ylabel('Magnitude (dB)')
xlabel('Frequency (MHz)')
title('Fourier Domain')

%% GENERATE DDS SIGNAL
a_sig_2 = 1;               % tone amplitude
f_sig_2 = (20)*1e6;        % tone frequency
dds_complex = a_sig_2*exp(1i*2*pi*f_sig_2*t);
%% MODULATE INPUT SIGNAL
out_complex = in_complex.*dds_complex;

%% PLOT OUTPUT DATA %%
x_out         = out_complex(1:NFFT);
out_spect_log = fftshift(20*log10(abs(fft(x_out)))); % log scale
out_spect_log = out_spect_log - max(out_spect_log); % normalize log scale
figure(2)
sgtitle(sprintf('Output %.0f MHz * %.0f MHz = %.0f MHz Waveform',...
    f_sig_1*1e-6, f_sig_2*1e-6, 1e-6*(f_sig_1+f_sig_2)))
subplot(2,1,1);
plot(t(1:500)*10^6,real(out_complex(1:500)), 'color', 'red')
ylabel('Real Signal')
xlabel('Time (microseconds)')
title('Time Domain')
subplot(2,1,2);
plot(freq_ax/1e6,out_spect_log(1:NFFT), 'color', 'red')
ylabel('Magnitude (dB)')
xlabel('Frequency (MHz)')
title('Fourier Domain')
