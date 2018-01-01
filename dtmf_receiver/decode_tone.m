function [row, col, energy_list] = decode_tone(xx_tone, fs)
% Dang Manh Truong (dangmanhtruong@gmail.com)
%   Detailed explanation goes here
L = numel(xx_tone);
Y = fft(xx_tone);
P2 = abs(Y/L);
P1 = P2(1:round(L/2)+1); % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;  

dtmf.keys = ... 
   ['1','2','3','A';
    '4','5','6','B';
    '7','8','9','C';
    '*','0','#','D'];

dtmf.colTones = ones(4,1)*[1209,1336,1477,1633];
dtmf.rowTones = [697;770;852;941]*ones(1,4);

% defines 1X8 vector of freqs
center_freqs = [dtmf.rowTones(:,1)' , dtmf.colTones(1,:)]; 
energy_list = zeros(1, numel(center_freqs));
for jj = 1 : length(center_freqs)
    selected_freq = center_freqs(jj);
    % We have to do this because on a computer everything is discrete
    % ...
    for ii = 1 : numel(f) - 1
        if (f(ii) <= selected_freq) && (f(ii + 1) >= selected_freq)
            before_temp = ii;
            after_temp = ii + 1;
        end
    end    
    energy = P1(before_temp);
    if energy < P1(after_temp)
        energy = P1(after_temp);
    end
    energy_list(jj) = energy;
end    
[~,ind] = max(energy_list(1:4));
lower_freq = center_freqs(ind);
row = ind;
[~,ind] = max(energy_list(5:8));
higher_freq = center_freqs(ind + 4);
col = ind;

end

