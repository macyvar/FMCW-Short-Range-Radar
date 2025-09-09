% make_tx_chirp_dat.m
%create baseband LFM chirp (complex) and save as float32 interleaved I/Q.

clear; clc;

%Parameters (must match processing & GRC)
Fs = 25e6;       % sample rate (Hz)
T  = 80e-6;      % chirp duration (s)
B  = 12e6;       % sweep bandwidth (Hz)

%output path (point your GRC File Source -> this file)
outpath = fullfile(getenv('HOME'),'fall_sr_dsgn','tx_chirp.dat');
if ~exist(fileparts(outpath),'dir'), mkdir(fileparts(outpath)); end

%build chirp 
Ns = round(Fs*T);
t  = (0:Ns-1).'/Fs;     % column vector
k  = B/T;               % sweep slope (Hz/s)
tx_chirp = exp(1j*pi*k*t.^2);   % complex baseband up-chirp

%save as float32 interleaved (I,Q,I,Q,...) 
fid = fopen(outpath,'wb');
assert(fid>0, 'Cannot open %s for writing', outpath);
interleaved = [real(tx_chirp) imag(tx_chirp)].';  % 2 x Ns
count = fwrite(fid, interleaved(:), 'float32');
fclose(fid);
assert(count == 2*Ns, 'Wrote %d floats, expected %d', count, 2*Ns);

fprintf('Wrote %s\nFs=%.1f MS/s, T=%.0f us, B=%.1f MHz, Ns=%d\n',...
    outpath, Fs/1e6, T*1e6, B/1e6, Ns);
fprintf('In GRC set: samp_rate=%.0f, and File Source -> %s\n', Fs, outpath);
