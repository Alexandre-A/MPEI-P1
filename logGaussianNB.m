function log_prob = logGaussianNB(x,mean_val,stdev)


if stdev > 0
    log_prob = log((1 / (stdev * sqrt(2 * pi))) * exp(-0.5 * ((x - mean_val) / stdev)^2));
end
end