function phase=phase_filter(phase)
    phase = reshape(phase,[8,10,3]);
    I_mean = mean(cos(phase),2);
    Q_mean = mean(sin(phase),2);
    %phase = phase-repmat(phase_mean,1,10);
    phase = repmat(atan2(Q_mean,I_mean),1,10);
    phase = reshape(phase,[80,3]);
end