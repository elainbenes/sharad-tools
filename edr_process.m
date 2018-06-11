function [ rdr,raw_returns ] = edr_process( edr )

%function [ rdr,raw_returns ] = edr_process( edr )
%
%   SHARAD Radar Data Parsing and Signal Processing Function
%   Michael Christoffersen
%   April 2016
%   Parses SHARAD EDR data from binary table, decompresses it, then performs pulse compression
%   with a reference chirp. Radargram is a .jpeg saved in the folder that the script is run from   
%
%
%   edr (string) - path to EDR file
%   refchirp (string) - path to reference chirp file
%   traces (integer) - traces of (number of traces in) EDR file
%   mode (integer 1-21) - radar mode for data take (omit the "ss", only put a number)
%   name (string) - desired name for the output .jpeg. Only put the first 
%                   part of the desired name, the file extension will be added by the function 
%
%   rdr - the matrix of processed traces, the step before the radargram is
%         made
%   raw_returns - matrix of unprocessed returns. This data is parsed from
%                 the binary file and decompressed, nothing else is done to
%                 it. Equivalent to running the edr_parse() and
%                 edr_decompress() functions on an EDR file

%n is number of presummed chirps in each trace (specific to mode)
%r is bit resolution of raw data (specific to mode)

%determine the traces of the radar line, and the instrument mode
[traces,mode] = lbl_parse([erase(edr,'_s.dat'),'.lbl']);

disp([traces,mode]);
[auxdata] = aux_parse([erase(edr,'_s.dat'),'_a.dat'],traces);
tx_avg = mean(auxdata(:,34));
rx_avg = mean(auxdata(:,35));

%

switch mode;
    case 1
        n=32;
        r=8;
    case 2
        n=28;
        r=6;
    case 3
        n=16;
        r=4;
    case 4
        n=8;
        r=8;
    case 5
        n=4;
        r=6;
    case 6
        n=2;
        r=4;
    case 7
        n=1;
        r=8;
    case 8
        n=32;
        r=6;
    case 9
        n=28;
        r=4;
    case 10
        n=16;
        r=8;
    case 11
        n=8;
        r=6;
    case 12
        n=4;
        r=4;
    case 13
        n=2;
        r=8;
    case 14
        n=1;
        r=6;
    case 15
        n=32;
        r=4;
    case 16
        n=28;
        r=8;
    case 17
        n=16;
        r=6;
    case 18
        n=8;
        r=4;
    case 19
        n=4;
        r=8;
    case 20
        n=2;
        r=6;
    case 21
        n=1;
        r=4;
    otherwise
        disp('Invalid Mode')
        return
end
                                                        

%% Parse and Process Sharad Binary Data
%Parse the science data file
returns = edr_parse(edr,traces,r); %use the last field in this command to specify how many traces to skip initially, leave it blank to skip none
raw_returns = returns;
disp('EDR parsed');
returns = edr_decompress(returns,n,r);
disp('EDR decompressed');

%Parse the chirp and combine the real and complex parts
chirp_freq = chirp_unpack(tx_avg,rx_avg);
disp('Ref. chirp unpacked');

%%
%method from http://pds-geosciences.wustl.edu/mro/mro-m-sharad-3-edr-v1/mroffrsh_0003/calib/calinfo.txt
returns = [returns,zeros(traces,(4096-3600))]; %zero padding the returns
returns = edr_complex_mult(returns,traces);
disp('EDR complex mult. complete');
returns = (returns.');
fftreturns = fft(returns);          %good through here
disp('FFT');



fftreturns = fftshift(fftreturns);
%%disp('FFT shift');
fftreturns = fftreturns(2045:4092,:);       %this is the subset Michael selects after performing fft-shift
%fftreturns = fftreturns(1025:3072,:);
chirp_freq = chirp_freq';
for n=1:traces
    fftreturns(:,n) = fftreturns(:,n).*chirp_freq;
end
disp('Here');
finalreturns = ifft(fftshift(fftreturns));
disp('IFFT');
name = [erase(edr,'_s.dat'),'_rgram'];
rgram(finalreturns,name);


end

