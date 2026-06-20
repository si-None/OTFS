function y_DD = OTFS_demodulation(N, M, r)
%% OTFS Demodulation: Wigner Transform + SFFT
%  Input:  r    - NM x 1 time domain received signal
%  Output: y_DD - N x M delay-Doppler domain symbols
r_mat = reshape(r, M, N);
Y_TF = fft(r_mat)/sqrt(M);              % Wigner transform
Y_TF = Y_TF.';
y_DD = ifft(fft(Y_TF).').'/sqrt(N/M);   % SFFT
end
