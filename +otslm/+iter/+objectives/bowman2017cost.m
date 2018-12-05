function f = bowman2017cost(target, trial, varargin)
% BOWMAN2017COST cost function used in Bowman et al. 2017 paper.
%
%   C = 10^d * (1.0 - \sum_{nm} sqrt(I_nm T_nm) cos(phi_nm - psi_nm)).^2
%
% target and trial should be the complex field amplitudes.
%
% Optional named arguments:
%     d     value     hyper-parameter of cost function (default: d = 9).
%     normalize  bool Normalize target/trial every evaluation (default=true).
%     roi   func      Region of interest mask to apply to target/trial.
%     type  str       Values to compare (both, phase, amplitude)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('d', 9.0);
p.addParameter('roi', @otslm.iter.objectives.roiAll);
p.addParameter('normalize', true);
p.addParameter('type', 'both');
p.parse(varargin{:});

% Apply mask to target and trial
[target, trial] = p.Results.roi(target, trial);

% Calculate the target intensity and amplitude
phi = angle(target);
T = abs(target).^2;

% Calculate the current intensity and amplitude
psi = angle(trial);
I = abs(trial).^2;

% Switch between the different types
switch p.Results.type
  case 'amplitude'
    % Throw away phase information
    phi = zeros(size(phi));
    psi = zeros(size(psi));
  case 'phase'
    % Throw away amplitude information
    I = ones(size(I));
    T = ones(size(T));
  otherwise
    % Keep both
end

% Calculate cost
overlap = sum(sqrt(T(:).*I(:)) .* cos(psi(:) - phi(:)));
if p.Results.normalize
  overlap = overlap / sqrt(sum(T(:)) * sum(I(:)));
end
f = 10^p.Results.d * (1.0 - overlap).^2;

