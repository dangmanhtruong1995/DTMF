function y = generateTone(f0,Fs,duration,mag)
%
% y = generateTone(f0,Fs,duration,mag)
%
% This function uses a digital oscillator implemented as a marginally
% stable IIR filter to generate a sinusoid at frequency f0 (in HZ) for
% "duration" seconds with a sampling frequency Fs (in Hz).  The absolute
% magnitude of the output will be "mag."
%


% Parameters
w0 = 2*pi*(f0/Fs); % desired frequency, rad/s
N = floor(duration*Fs); % number of samples

y = zeros(1,N);
% initial conditions for IIR filter / digital oscillator
% y(-1)=y(-2)=0.
y(0+1) = mag*sin(w0); % y(0)
y(1+1) = 2*cos(w0)*y(0+1); % y(1)
y(2+1) = 2*cos(w0)*y(1+1)-y(0+1); % y(2)
for n = 3:N-1; 
    y(n+1) = 2*cos(w0)*y(n-1+1)-y(n-2+1); % digital oscillator, marginally stable IIR filter
end
