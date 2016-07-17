function [ nWD, f, t ] = wvd( x, Fs )
%WVD compute discrete wigner-ville distribution
% x - analytic signal
% Fs - sampling frequency

[N, xcol] = size(x);
if N<xcol
    x = x.';
    N = xcol;
end

WD = zeros(N,N);
t = (1:N)./Fs;
f = (1:N).*Fs/(N);

ti=int32(1);

for ti = 1:N
% taumax = min([ti-1,N-ti,round(N/2)-1]);
    tau = -min([ti-1,N-ti]):min([ti-1,N-ti]);
    WD(tau-tau(1)+1,ti) = x(ti+tau).*conj(x(ti-tau));
end

nWD = 2.*fft(WD);

end