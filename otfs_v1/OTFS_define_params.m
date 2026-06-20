function params = OTFS_define_params()
% OTFS_DEFINE_PARAMS CP-OTFS sistemi için tüm sabit parametreleri tanımlar.

% OTFS parametreleri
params.N = 16;        % Doppler hücre sayısı (OFDM sembol sayısı)
params.M = 128;       % Gecikme hücre sayısı (FFT boyutu)
params.Ncp = 16;      % Döngüsel önek uzunluğu

% DD ızgarası bölümleme
params.Mz = ceil(0.0666 * params.M);  % Koruma bandı (9)
params.Md = 100;                       % Doppler başına veri sembolü
params.Mp = params.M - params.Md - params.Mz; % Pilot sembolü (19)

% Pilot pozisyonu ve değeri
params.np = 8;         % Pilot Doppler indeksi
params.mp = 8;         % Pilot gecikme indeksi
params.pilotValue = 10 + 10i;

% Modülasyon
params.M_mod = 4;      % QPSK
params.M_bits = log2(params.M_mod);
params.N_syms_perfram = params.N * params.Md; % 1600
params.N_bits_perfram = params.N_syms_perfram * params.M_bits; % 3200

% Sıfır dolgu uzunluğu
params.Nzp = 50;

% Preamble (Zadoff-Chu dizisi)
params.preamble = zadoffChuSeq(25, 193);

% RF parametreleri
params.rfTxFreq = 2.5e9;
params.MasterClockRate = 20e6;
params.Fs = 200e3;

% Türetilmiş uzunluklar
params.cpOtfsLen = params.N * params.M + params.Ncp; % 2048+16=2064
params.unitFrame = length(params.preamble) + params.Nzp + 2*params.cpOtfsLen;

end