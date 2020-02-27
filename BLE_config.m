function BLE=BLE_config()
BLE.freq=2402e6;
BLE.c=299792458;
BLE.R=BLE.c/BLE.freq/2;%half wave length of BLE
BLE.num_ant=3;

end
