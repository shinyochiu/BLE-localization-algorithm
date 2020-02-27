# BLE-localization-algorithm

The system is built up based on TI instrument's CC2640R2 launchpad, the receiver will send the IQ data to PC through the serial in the form of HEX, we use read_file16.m to preprocess the data into DEC.

Run main.m for the real time BLE localization algorithm.

Run CRLB_run.m and SPEB_run.m to evaluate the performance of the algorithm and run CRLB_plot.m, SPEB_plot.m to show the results.

The algorithm is based on weighted LS. By minimizing the objective function of the phase observations, we can obtain a coarse estimation, and then assign the weight to each sample according to the estimated carrier frequency offset.

The weighting can be modified in weighted.m, and the weighted LS can be modified in search_test.m.

For single anchor scenario, a basic RSSI based distance estimate is provided in TOF.m, and the final localization is smoothed by Kalman filter.
