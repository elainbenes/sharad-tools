dt = (3/80)*10^(-6);
fs = 1/dt;
N = 4096;
rl = 1/fs*N;
f = zeros(1,N);
time_vec = 0:dt:4095*dt;


for i = 1:N-1
    f(i+1) = i/rl;
end

%account for hermitian symmetry 
for k = 1:(N/2)-1
  f((N/2)+k+1)=-f((N/2)-k+1);
end


%% select the appropriate reference chirp based on input temps

%disp('Enter temperatures in degrees celsius for the transmitter and receiver to choose the appropriate reference chirp.')
%disp('Temperatures may range from ~ -20C to ~ +60C.')
%tx_avg = input('TX-temp: ');
%rx_avg = input('RX-temp: ');
tx_avg = randi([-40,60]);
rx_avg = randi([-40,60]);

%set random temps without certain range for testing
chirp_freq = chirp_unpack(tx_avg,rx_avg);



%% test pulse compression of reference chirp with itself. this should produce a nice response

returns_pad = [chirp_freq,zeros(1,(4096-length(chirp_freq)))]; %zero padding the returns\\

chirp_freq = chirp_freq';

returns_compl = edr_complex_mult(returns_pad,1);

fftreturns_noShift = fft(returns_compl);
fftreturns_noShift_subset = fftreturns_noShift(1025:3072,:);
range_compress_noShift(:,1) = fftreturns_noShift_subset(:,1).*chirp_freq;
finalreturns_noShift = ifft((range_compress_noShift));

fftreturns_noShift_subset_flip = fftreturns_noShift([2050:3073,1025:2048],:); 
range_compress_noShift_flip(:,1) = fftreturns_noShift_subset_flip(:,1).*chirp_freq;
finalreturns_noShift_flip = ifft((range_compress_noShift_flip));

fftreturns_shift = fftshift(fft(returns_compl));
fftreturns_shift_subset = fftreturns_shift(1025:3072,:);
range_compress_shift(:,1) = fftreturns_shift_subset(:,1).*chirp_freq;
finalreturns_shift = ifft((range_compress_shift));



%% figure
close all
subplot 211
plot(f./1e6)
title('Frequency spectrum')
xlabel('frame')
ylabel('frequency [MHz]')
subplot 212
plot(fftshift(f)./1e6)
title('Shifted frequency spectrum')
xlabel('frame')
ylabel('frequency [MHz]')




figure
subplot 511
plot((abs(chirp_freq)).^2);
title('Chirp power spectrum');
subplot 512
plot((abs(returns_compl)).^2);
title('Zero-padded power spectrum');
subplot 513
plot((abs(finalreturns_noShift)).^2);
title('Range compressed output of non-shifted spectrum');
subplot 514
plot((abs(finalreturns_shift)).^2);
title('Range compressed output of shifted spectrum');
subplot 515
plot((abs(finalreturns_noShift_flip)).^2);
