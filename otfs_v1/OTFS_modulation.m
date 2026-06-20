function s = OTFS_modulation(N, M, x_DD)
%% OTFS Modulation: ISFFT + Heisenberg Transform
%  Input:  x_DD  - N x M delay-Doppler domain symbols
%  Output: s     - NM x 1 time domain signal
X_TF = fft(ifft(x_DD).').'/sqrt(M/N);   % ISFFT
s_mat = ifft(X_TF.')*sqrt(M);           % Heisenberg transform
s = s_mat(:);
end
