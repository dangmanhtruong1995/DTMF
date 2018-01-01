# DTMF
Transmit text data through sound between 2 computers using DTMF (Dual Tone Multi Frequency signaling)

The original DTMF has 16 signals each using a combination of 2 frequencies. But here I only used "1"(697 Hz and 1209 Hz) and "0" (941Hz and 1336 Hz). The text is converted into binary form and then sent through the sound card. On the receiver side, the sound is converted into binary and then back to text.

Unlike many other pieces of modulation/demodulation code on the internet, this one has actually been tested in the wild :)

An outline of how the code works:
- The sender converts text to binary, then transmit "0" / "1" DTMF signals (here the timing is 0.3s for tone duration, and 0.1s for silence period between tones ). The transmission code is taken from: https://sites.google.com/a/nd.edu/adsp-nik-kleber/home/advanced-digital-signal-processing/project-3-touch-tone . Apparently the author used a marginally stable IIR filter to implement a digital oscillator. 
- The receiver side first uses 2 ridiculously-high-ordered-and-ridiculously-narrow bandpass filters to extract the "0" and "1" frequency components, respectively:

filter_order = 1000;
one_band = [[((2*696)/Fs) ((2*698)/Fs)] [((2*1208)/Fs) ((2*1210)/Fs)]];
one_dtmf_filter = fir1(filter_order, one_band);
zero_band = [[((2*940)/Fs) ((2*942)/Fs)] [((2*1335)/Fs) ((2*1337)/Fs)]];
zero_dtmf_filter = fir1(filter_order, zero_band);

After this is done we will find the beginning and end of each "1" and "0" signal. The code is from https://github.com/codyaray/dtmf-signaling. Basically it finds the silence period which is at least 10 ms and any tone period more than 100ms) :

![](https://user-images.githubusercontent.com/20016033/34468682-cf381b6e-ef40-11e7-924f-c2539cbfe28d.PNG?raw=true "")
(From top to bottom: Zero signal, signal after moving average filter, difference of signal after removing those below threshold, signal after thresholding)
- First the result from the previous step is normalized then went through a moving average filter (with filter size equals 10ms * Fs). If we plot the result we would see that the shape of the "0" and "1" can clearly be seen. So I think it kinda works as an envelope detector in this case.
- Then all the signal below a certain threshold is cut off (I chose 0.1). 
- Finally find all intervals above the threshold that has a time interval greater than 100ms
(note that the image is not reproducible from the code, you will have to dig around to make it)


Then we assemble the bits and convert back into text :)

Video demo: 

[![DEMO ](https://user-images.githubusercontent.com/20016033/34468760-57425190-ef42-11e7-9024-8c18dfbe21b2.PNG)](https://www.youtube.com/watch?v=vwQVmNnWa4s "DEMO")


