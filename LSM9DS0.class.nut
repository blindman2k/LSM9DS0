// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT
//
// Driver Class for Inertial Measurement Unit LSM9DS0
// http://www.adafruit.com/datasheets/LSM9DS0.pdf

class LSM9DS0 {
    
    static WHO_AM_I_G       = 0x0F;
    static CTRL_REG1_G      = 0x20;
    static CTRL_REG2_G      = 0x21;
    static CTRL_REG3_G      = 0x22;
    static CTRL_REG4_G      = 0x23;
    static CTRL_REG5_G      = 0x24;
    static REF_DATACAP_G    = 0x25;
    static STATUS_REG_G     = 0x27;
    static OUT_X_L_G        = 0x28;
    static OUT_X_H_G        = 0x29;
    static OUT_Y_L_G        = 0x2A;
    static OUT_Y_H_G        = 0x2B;
    static OUT_Z_L_G        = 0x2C;
    static OUT_Z_H_G        = 0x2D;
    static FIFO_CTRL_REG_G  = 0x2E;
    static FIFO_SRC_REG_G   = 0x2F;
    static INT1_CFG_G       = 0x30;
    static INT1_SRC_G       = 0x31;
    static INT1_THS_XH_G    = 0x32;
    static INT1_THS_XL_G    = 0x33;
    static INT1_THS_YH_G    = 0x34;
    static INT1_THS_YL_G    = 0x35;
    static INT1_THS_ZH_G    = 0x36;
    static INT1_THS_ZL_G    = 0x37;
    static INT1_DURATION_G  = 0x38;
    static OUT_TEMP_L_XM    = 0x05;
    static OUT_TEMP_H_XM    = 0x06;
    static STATUS_REG_M     = 0x07;
    static OUT_X_L_M        = 0x08;
    static OUT_X_H_M        = 0x09;
    static OUT_Y_L_M        = 0x0A;
    static OUT_Y_H_M        = 0x0B;
    static OUT_Z_L_M        = 0x0C;
    static OUT_Z_H_M        = 0x0D;
    static WHO_AM_I_XM      = 0x0F;
    static INT_CTRL_REG_M   = 0x12;
    static INT_SRC_REG_M    = 0x13;
    static INT_THS_L_M      = 0x14;
    static INT_THS_H_M      = 0x15;
    static OFFSET_X_L_M     = 0x16;
    static OFFSET_X_H_M     = 0x17;
    static OFFSET_Y_L_M     = 0x18;
    static OFFSET_Y_H_M     = 0x19;
    static OFFSET_Z_L_M     = 0x1A;
    static OFFSET_Z_H_M     = 0x1B;
    static REFERENCE_X      = 0x1C;
    static REFERENCE_Y      = 0x1D;
    static REFERENCE_Z      = 0x1E;
    static CTRL_REG0_XM     = 0x1F;
    static CTRL_REG1_XM     = 0x20;
    static CTRL_REG2_XM     = 0x21;
    static CTRL_REG3_XM     = 0x22;
    static CTRL_REG4_XM     = 0x23;
    static CTRL_REG5_XM     = 0x24;
    static CTRL_REG6_XM     = 0x25;
    static CTRL_REG7_XM     = 0x26;
    static STATUS_REG_A     = 0x27;
    static OUT_X_L_A        = 0x28;
    static OUT_X_H_A        = 0x29;
    static OUT_Y_L_A        = 0x2A;
    static OUT_Y_H_A        = 0x2B;
    static OUT_Z_L_A        = 0x2C;
    static OUT_Z_H_A        = 0x2D;
    static FIFO_CTRL_REG    = 0x2E;
    static FIFO_SRC_REG     = 0x2F;
    static INT_GEN_1_REG    = 0x30;
    static INT_GEN_1_SRC    = 0x31;
    static INT_GEN_1_THS    = 0x32;
    static INT_GEN_1_DURATION = 0x33;
    static INT_GEN_2_REG    = 0x34;
    static INT_GEN_2_SRC    = 0x35;
    static INT_GEN_2_THS    = 0x36;
    static INT_GEN_2_DURATION = 0x37;
    static CLICK_CFG        = 0x38;
    static CLICK_SRC        = 0x39;
    static CLICK_THS        = 0x3A;
    static TIME_LIMIT       = 0x3B;
    static TIME_LATENCY     = 0x3C;
    static TIME_WINDOW      = 0x3D;
    static Act_THS          = 0x3E;
    static Act_DUR          = 0x3F;
    
    _i2c        = null;
    _xm_addr    = null;
    _g_addr     = null;
    
    _temp_enabled = null;
    
    // -------------------------------------------------------------------------
    constructor(i2c, xm_addr = 0x3A, g_addr = 0xD4) {
        _i2c = i2c;
        _xm_addr = xm_addr;
        _g_addr = g_addr;
        
        _temp_enabled = false;
        
        init();
    }
    
    // -------------------------------------------------------------------------
    function init() {
    }
    
    // -------------------------------------------------------------------------
    function _twosComp(value, mask) {
        value = ~(value & mask) + 1;
        return value & mask;
    }
    
    // -------------------------------------------------------------------------
    function _getReg(addr, reg) {
        local val = _i2c.read(addr, format("%c", reg), 1);
        if (val != null) {
            return val[0];
        } else {
            return null;
        }
    }
    
    // -------------------------------------------------------------------------
    function _setReg(addr, reg, val) {
        _i2c.write(addr, format("%c%c", reg, (val & 0xff)));   
    }
    
    // -------------------------------------------------------------------------
    function _setRegBit(addr, reg, bit, state) {
        local val = _getReg(addr, reg);
        if (state == 0) {
            val = val & ~(0x01 << bit);
        } else {
            val = val | (0x01 << bit);
        }
        _setReg(addr, reg, val);
    }
    
    function dumpCtrlRegs() {
        server.log(format("CTRL_REG0: 0x%02X", _getReg(_xm_addr, CTRL_REG0_XM)));
        server.log(format("CTRL_REG1: 0x%02X", _getReg(_xm_addr, CTRL_REG1_XM)));
        server.log(format("CTRL_REG2: 0x%02X", _getReg(_xm_addr, CTRL_REG2_XM)));
        server.log(format("CTRL_REG3: 0x%02X", _getReg(_xm_addr, CTRL_REG3_XM)));
        server.log(format("CTRL_REG4: 0x%02X", _getReg(_xm_addr, CTRL_REG4_XM)));
        server.log(format("CTRL_REG5: 0x%02X", _getReg(_xm_addr, CTRL_REG5_XM)));
        server.log(format("CTRL_REG6: 0x%02X", _getReg(_xm_addr, CTRL_REG6_XM)));
        server.log(format("CTRL_REG7: 0x%02X", _getReg(_xm_addr, CTRL_REG7_XM)));
        server.log(format("INT_CTRL_REG_M: 0x%02X", _getReg(_xm_addr, INT_CTRL_REG_M)));
        server.log(format("INT_GEN_1_REG: 0x%02X", _getReg(_xm_addr, INT_GEN_1_REG)));
        server.log(format("INT_GEN_1_THS: 0x%02X", _getReg(_xm_addr, INT_GEN_1_THS)));
        server.log(format("INT_GEN_1_DURATION: 0x%02X", _getReg(_xm_addr, INT_GEN_1_DURATION)));
    }
    
    // -------------------------------------------------------------------------
    // Return Gyro Device ID (0xD4)
    function getDeviceId_G() {
        return _getReg(_g_addr, WHO_AM_I_G);
    }
    
    // -------------------------------------------------------------------------
    // set power state of the gyro device
    // note that if individual axes were previously disabled, they still will be
    function setPowerState_G(state) {
        _setRegBit(_g_addr, CTRL_REG1_G, 3, state);
    }
    
    // -------------------------------------------------------------------------
    function setPowerState_GZ(state) {
        _setRegBit(_g_addr, CTRL_REG1_G, 2, state);
    }
    
    // -------------------------------------------------------------------------
    function setPowerState_GY(state) {
        _setRegBit(_g_addr, CTRL_REG1_G, 1, state);
    }
    
    // -------------------------------------------------------------------------
    function setPowerState_GX(state) {
        _setRegBit(_g_addr, CTRL_REG1_G, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // set high to enable interrupt generation from the gyro
    function setIntEnable_G(state) {
        _setRegBit(_g_addr, CTRL_REG3_G, 7, state);
    }
    
    // -------------------------------------------------------------------------
    // set high to enable active-low interrupt on gyro interrupt
    // set low to enable active-high
    function setIntActivelow_G(state) {
        _setRegBit(_g_addr, CTRL_REG3_G, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // set high to enable open-drain output on gyro interrupt
    // set low to enable push-pull
    function setIntOpendrain_G(state) {
        _setRegBit(_g_addr, CTRL_REG3_G, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // Generate interrupt on data-ready
    function setIntDrdy_G(state) {
        _setRegBit(_g_addr, CTRL_REG3_G, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt latch for gyro interrupts
    function setIntLatchEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 6, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt generation on Z high event
    function setIntZhighEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt generation on Z low event
    function setIntZlowEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt generation on Y high event
    function setIntYhighEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt generation on Y low event
    function setIntYlowEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt generation on X high event
    function setIntXhighEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 1, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt generation on X low event
    function setIntXlowEn_G(state) {
        _setRegBit(_g_addr, INT1_CFG_G, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // set the gyro threshold values for interrupt
    function setIntThs_G(x_ths, y_ths, z_ths) {
        _setReg(_g_addr, INT1_THS_XH_G, (x_ths & 0xff00) >> 8);
        _setReg(_g_addr, INT1_THS_XL_G, (x_ths & 0xff));
        _setReg(_g_addr, INT1_THS_YH_G, (y_ths & 0xff00) >> 8);
        _setReg(_g_addr, INT1_THS_YL_G, (y_ths & 0xff));
        _setReg(_g_addr, INT1_THS_ZH_G, (z_ths & 0xff00) >> 8);
        _setReg(_g_addr, INT1_THS_ZL_G, (z_ths & 0xff));
    }
    
    // -------------------------------------------------------------------------
    // set number of over-threshold samples to count before throwing interrupt
    function setIntDuration_G(nsamples) {
        _setReg(_g_addr, INT1_DURATION_G, nsamples & 0xff);
    }
    
    // -------------------------------------------------------------------------
    // read the interrupt source register to determine what caused an interrupt
    function getIntSrc_G() {
        return _getReg(_g_addr, INT1_SRC_G);
    }
    
    // -------------------------------------------------------------------------
    // Enable/disable FIFO for gyro
    function setFifoEn_G(state) {
        _setRegBit(_g_addr, CTRL_REG5_G, 6, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable/disable Gyro High-Pass Filter
    function setHpfEn_G(state) {
        _setRegBit(_g_addr, CTRL_REG5_G, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // Returns Accel/Magnetometer Device ID (0x49)
    function getDeviceId_XM() {
        return _getReg(_xm_addr, WHO_AM_I_XM);
    }
    
    // -------------------------------------------------------------------------
    // read the magnetometer's status register
    function getStatus_M() {
        return _getReg(_xm_addr, STATUS_REG_M);
    }
    
    // -------------------------------------------------------------------------
    // Put magnetometer into continuous-conversion mode
    // IMU comes up with magnetometer powered down
    function setModeCont_M() {
        local val = _getReg(_xm_addr, CTRL_REG7_XM) & 0xFC;
        // bits 1:0 determine mode
        // 0b00 -> continuous conversion mode
        _setReg(_xm_addr, CTRL_REG7_XM, val);
    }
    
    // -------------------------------------------------------------------------
    // Put magnetometer into single-conversion mode
    function setModeSingle_M() {
        local val = _getReg(_xm_addr, CTRL_REG7_XM) & 0xFC;
        // 0b01 -> single conversion mode
        val = val | 0x01;
        _setReg(_xm_addr, CTRL_REG7_XM, val);
    }
    
    // -------------------------------------------------------------------------
    // Put magnetometer into power-down mode
    function setModePowerdown_M() {
        local val = _getReg(_xm_addr, CTRL_REG7_XM) & 0xFC;
        // 0b10 or 0b11 -> power-down mode
        val = val | 0x20;
        _setReg(_xm_addr, CTRL_REG7_XM, val);
    }
    
    // -------------------------------------------------------------------------
    // Enable interrupt generation on x axis for magnetic data
    function setIntEn_MX(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 7, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable interrupt generation on y axis for magnetic data
    function setIntEn_MY(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 6, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable interrupt generation on z axis for magnetic data
    function setIntEn_MZ(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // set high to enable interrupt generation from the magnetometer
    function setIntEn_M(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // set high to enable active-high interrupt for accel/mag
    // set low to enable active-low
    function setIntActivehigh_XM(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // set high to enable open-drain output for accel/mag
    // set low to enable push-pull
    function setIntOpendrain_XM(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // enable/disable interrupt latching for accel/magnetometer
    // if set, clear interrupt by reading INT_GEN_1_SRC, INT_GEN_2_SRC, AND INT_SRC_REG_M
    function setIntLatch_XM(state) {
        _setRegBit(_xm_addr, INT_CTRL_REG_M, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // read the interrupt source register to determine what caused an interrupt
    function getIntSrc_M() {
        return _getReg(xm_addr, INT_SRC_REG_M);
    }
    
    // -------------------------------------------------------------------------
    // set the absolute value of the magnetometer interrupt threshold for all axes
    function setIntThs_M(val) {
        _setReg(_xm_addr, INT_THS_H_M, (val & 0xff00) << 8);
        _setReg(_xm_addr, INT_THS_L_M, (val & 0xff));
    }
    
    // -------------------------------------------------------------------------
    // Enable/disable high-pass filter for click detection interrupt 
    function setHpfClick_XM(state) {
        _setRegBit(_xm_addr, CTRL_REG0_XM, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable/disable high-pass filter for interrupt generator 1
    function setHpfInt1_XM(state) {
        _setRegBit(_xm_addr, CTRL_REG0_XM, 1, state);
    }
    
    // -------------------------------------------------------------------------
    function setHpfInt2_XM(state) {
        _setRegBit(_xm_addr, CTRL_REG0_XM, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // Set Accelerometer Data Rate in Hz
    // IMU comes up with accelerometer disabled; rate must be set to enable
    function setDatarate_A(rate) {
        local val = _getReg(_xm_addr, CTRL_REG1_XM) & 0x0F;
        if (rate == 0) {
            // 0b0000 -> power-down mode
            // we've already ANDed-out the top 4 bits; just write back
        } else if (rate <= 3.125) {
            val = val | 0x10; 
        } else if (rate <= 6.25) {
            val = val | 0x20;
        } else if (rate <= 12.5) {
            val = val | 0x30;
        } else if (rate <= 25) {
            val = val | 0x40;
        } else if (rate <= 50) {
            val = val | 0x50;
        } else if (rate <= 100) {
            val = val | 0x60;
        } else if (rate <= 200) {
            val = val | 0x70;
        } else if (rate <= 400) {
            val = val | 0x80;
        } else if (rate <= 800) {
            val = val | 0x90;
        } else if (rate <= 1600) {
            val = val | 0xA0;
        }
        _setReg(_xm_addr, CTRL_REG1_XM, val);
    }
    
    // -------------------------------------------------------------------------
    // Enable/Disable X-axis accelerometer
    function setEnableX_A(state) {
        _setRegBit(_xm_addr, CTRL_REG1_XM, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable/Disable Y-axis accelerometer
    function setEnableY_A(state) {
        _setRegBit(_xm_addr, CTRL_REG1_XM, 1, state);;
    }
    
    // -------------------------------------------------------------------------
    // Enable/Disable Z-axis accelerometer
    function setEnableZ_A(state) {
        _setRegBit(_xm_addr, CTRL_REG1_XM, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // Set Magnetometer Data Rate in Hz
    // IMU comes up with magnetometer data rate set to 3.125 Hz
    function setDatarate_M(rate) {
        local val = _getReg(_xm_addr, CTRL_REG5_XM) & 0xE3;
        if (rate <= 3.125) {
            // rate already set; 0x0
        } else if (rate <= 6.25) {
            val = val | (0x01 << 3);
        } else if (rate <= 12.5) {
            val = val | (0x02 << 3);
        } else if (rate <= 25) {
            val = val | (0x03 << 3);
        } else if (rate <= 50) {
            val = val | (0x04 << 3);
        } else {
            // rate = 100 Hz
            val = val | (0x05 << 3);
        } 
        _setReg(_xm_addr, CTRL_REG5_XM, val);
    }
    
    // -------------------------------------------------------------------------
    // Enable Interrupt Generation on INT1_XM on "tap" event
    function setTapIntEn_P1(state) {
        _setRegBit(_xm_addr, CTRL_REG3_XM, 6, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Inertial Interrupt Generator 1 on INT1_XM
    function setInertInt1En_P1(state) {
        _setRegBit(_xm_addr, CTRL_REG3_XM, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Inertial Interrupt Generator 2 on INT1_XM
    function setInertInt2En_P1(state) {
        _setRegBit(_xm_addr, CTRL_REG3_XM, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Magnetic Interrupt on INT1_XM
    function setMagIntEn_P1(state) {
        _setRegBit(_xm_addr, CTRL_REG3_XM, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Accel Data Ready Interrupt INT1_XM
    function setAccelDrdyIntEn_P1(state) {
        _setRegBit(_xm_addr, CTRL_REG3_XM, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Magnetometer Data Ready Interrupt INT1_XM
    function setMagDrdyIntEn_P1(state) {
        _setRegBit(_xm_addr, CTRL_REG3_XM, 1, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Interrupt Generation on INT2_XM on "tap" event
    function setTapIntEn_P2(state) {
        _setRegBit(_xm_addr, CTRL_REG4_XM, 7, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Inertial Interrupt Generator 1 on INT2_XM
    function setInertInt1En_P2(state) {
        _setRegBit(_xm_addr, CTRL_REG4_XM, 6, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Inertial Interrupt Generator 2 on INT2_XM
    function setInertInt2En_P2(state) {
        _setRegBit(_xm_addr, CTRL_REG4_XM, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Magnetic Interrupt on INT2_XM
    function setMagIntEn_P2(state) {
        _setRegBit(_xm_addr, CTRL_REG4_XM, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Accel Data Ready Interrupt INT2_XM
    function setAccelDrdyIntEn_P2(state) {
        _setRegBit(_xm_addr, CTRL_REG4_XM, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable Magnetometer Data Ready Interrupt INT2_XM
    function setMagDrdyIntEn_p2(state) {
        _setRegBit(_xm_addr, CTRL_REG4_XM, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable / Disable Interrupt Latching on XM_INT2 Pin
    function setInt2LatchEn_XM(state) {
        _setRegBit(_xm_addr, CTRL_REG5_XM, 1, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable / Disable Interrupt Latching onh XM_INT1 Pin
    function setInt1LatchEn_XM(state) {
        _setRegBit(_xm_addr, CTRL_REG5_XM, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // Enable temperature sensor
    function setTempEn(state) {
        _setRegBit(_xm_addr, CTRL_REG5_XM, 7, state);
        if (state == 0) {
            _temp_enabled = false;
        } else {
            _temp_enabled = true;
        }
    }

    // -------------------------------------------------------------------------
    // read the accelerometer's status register
    function getStatus_A() {
        return _getReg(_xm_addr, STATUS_REG_A);
    }    
    
    // -------------------------------------------------------------------------
    function getInt1Src_XM() {
        return _getReg(_xm_addr, INT_GEN_1_SRC);
    }
    
    // -------------------------------------------------------------------------
    function getInt2Src_XM() {
        return _getReg(_xm_addr, INT_GEN_2_SRC);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 1 generation on Z high event
    function setInt1ZhighEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_1_REG, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 1 generation on Z low event
    function setInt1ZlowEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_1_REG, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 1 generation on Y high event
    function setInt1YhighEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_1_REG, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 1 generation on Y low event
    function setInt1YlowEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_1_REG, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 1 generation on X high event
    function setInt1XhighEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_1_REG, 1, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 1 generation on X low event
    function setInt1XlowEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_1_REG, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // set the accelerometer threshold value interrupt 1
    function setInt1Ths_A(ths) {
        _setReg(_xm_addr,  INT_GEN_1_THS, (ths & 0x7f));
    }
    
    // -------------------------------------------------------------------------
    // set the event duration over threshold before throwing interrupt
    // duration steps and max values depend on selected ODR
    function setInt1Duration_A(duration) {
        _setReg(_xm_addr, INT_GEN_1_DURATION, duration & 0x7f);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 2 generation on Z high event
    function setInt2ZhighEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_2_REG, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 2 generation on Z low event
    function setInt2ZlowEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_2_REG, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 2 generation on Y high event
    function setInt2YhighEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_2_REG, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 2 generation on Y low event
    function setInt2YlowEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_2_REG, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 2 generation on X high event
    function setInt2XhighEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_2_REG, 1, state);
    }
    
    // -------------------------------------------------------------------------
    // enable interrupt 2 generation on X low event
    function setInt2XlowEn_A(state) {
        _setRegBit(_xm_addr, INT_GEN_2_REG, 0, state);
    }
    
    // -------------------------------------------------------------------------
    // set the accelerometer threshold value interrupt 2
    function setInt2Ths_A(ths) {
        _setReg(_xm_addr, INT_GEN_2_THS, (ths & 0x7f));
    }
    
    // -------------------------------------------------------------------------
    // set the event duration over threshold before throwing interrupt
    // duration steps and max values depend on selected ODR
    function setInt2Duration_A(duration) {
        _setReg(_xm_addr, INT_GEN_2_DURATION, duration & 0x7f);
    }
    
    // -------------------------------------------------------------------------
    // enable / disable double-click detection on z-axis
    function setDblclickIntEn_Z(state) {
        _setRegBit(_xm_addr, CLICK_CFG, 5, state);
    }
    
    // -------------------------------------------------------------------------
    // enable / disable single-click detection on z-axis
    function setSnglclickIntEn_Z(state) {
        _setRegBit(_xm_addr, CLICK_CFG, 4, state);
    }
    
    // -------------------------------------------------------------------------
    // enable / disable double-click detection on y-axis
    function setDblclickIntEn_Y(state) {
        _setRegBit(_xm_addr, CLICK_CFG, 3, state);
    }
    
    // -------------------------------------------------------------------------
    // enable / disable single-click detection on y-axis
    function setSnglclickIntEn_Y(state) {
        _setRegBit(_xm_addr, CLICK_CFG, 2, state);
    }
    
    // -------------------------------------------------------------------------
    // enable / disable double-click detection on x-axis
    function setDblclickIntEn_X(state) {
        _setRegBit(_xm_addr, CLICK_CFG, 1, state);
    }
    
    // -------------------------------------------------------------------------
    // enable / disable single-click detection on x-axis
    function setSnglclickIntEn_X(state) {
        _setRegBit(_xm_addr, CLICK_CFG, 0, state);
    }
    
    // -------------------------------------------------------------------------
    function clickIntActive() {
        return (0x40 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    function dblclickDet() {
        return (0x20 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    function snglclickDet() {
        return (0x10 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    function clickNegDir() {
        return (0x08 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    function zclickDet() {
        return (0x04 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    function yclickDet() {
        return (0x02 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    function xclickDet() {
        return (0x01 & _getReg(_xm_addr, CLICK_SRC)); 
    }
    
    // -------------------------------------------------------------------------
    // set the click detection threshold
    function setClickDetThs(ths) {
        _setReg(_xm_addr, CLICK_THS, (ths & 0x7f));
    }
    
    // -------------------------------------------------------------------------
    // read the internal temperature sensor in the accelerometer / magnetometer
    function getTemp() {
        if (!_temp_enabled) { setTempEn(1) };
        local temp = (_getReg(_xm_addr, OUT_TEMP_H_XM) << 8) + _getReg(_xm_addr, OUT_TEMP_L_XM);
        temp = temp & 0x0fff; // temp data is 12 bits, 2's comp, right-justified
        if (temp & 0x0800) {
            return (-1.0) * _twosComp(temp, 0x0fff);
        } else {
            return temp;
        }
    }
    
    // -------------------------------------------------------------------------
    // Read data from the Gyro
    // Returns a table {x: <data>, y: <data>, z: <data>}
    function getGyro() {
        local x_raw = (_getReg(_g_addr, OUT_X_H_G) << 8) + _getReg(_g_addr, OUT_X_L_G);
        local y_raw = (_getReg(_g_addr, OUT_Y_H_G) << 8) + _getReg(_g_addr, OUT_Y_L_G);
        local z_raw = (_getReg(_g_addr, OUT_Z_H_G) << 8) + _getReg(_g_addr, OUT_Z_L_G);
        
        local result = {};
        if (x_raw & 0x8000) {
            result.x <- (-1.0) * _twosComp(x_raw, 0xffff);
        } else {
            result.x <- x_raw;
        }
        
        if (y_raw & 0x8000) {
            result.y <- (-1.0) * _twosComp(y_raw, 0xffff);
        } else {
            result.y <- y_raw;
        }
        
        if (z_raw & 0x8000) {
            result.z <- (-1.0) * _twosComp(z_raw, 0xffff);
        } else {
            result.z <- z_raw;
        }
        
        return result;
    }
    
    // -------------------------------------------------------------------------
    // Read data from the Magnetometer
    // Returns a table {x: <data>, y: <data>, z: <data>}
    function getMag() {
        local x_raw = (_getReg(_xm_addr, OUT_X_H_M) << 8) + _getReg(_xm_addr, OUT_X_L_M);
        local y_raw = (_getReg(_xm_addr, OUT_Y_H_M) << 8) + _getReg(_xm_addr, OUT_Y_L_M);
        local z_raw = (_getReg(_xm_addr, OUT_Z_H_M) << 8) + _getReg(_xm_addr, OUT_Z_L_M);
    
        local result = {};
        if (x_raw & 0x8000) {
            result.x <- (-1.0) * _twosComp(x_raw, 0xffff);
        } else {
            result.x <- x_raw;
        }
        
        if (y_raw & 0x8000) {
            result.y <- (-1.0) * _twosComp(y_raw, 0xffff);
        } else {
            result.y <- y_raw;
        }
        
        if (z_raw & 0x8000) {
            result.z <- (-1.0) * _twosComp(z_raw, 0xffff);
        } else {
            result.z <- z_raw;
        }
        
        return result;
    }
    
    // -------------------------------------------------------------------------
    // Read data from the Accelerometer
    // Returns a table {x: <data>, y: <data>, z: <data>}
    function getAccel() {
        local x_raw = (_getReg(_xm_addr, OUT_X_H_A) << 8) + _getReg(_xm_addr, OUT_X_L_A);
        local y_raw = (_getReg(_xm_addr, OUT_Y_H_A) << 8) + _getReg(_xm_addr, OUT_Y_L_A);
        local z_raw = (_getReg(_xm_addr, OUT_Z_H_A) << 8) + _getReg(_xm_addr, OUT_Z_L_A);

        //server.log(format("%02X, %02X, %02X",x_raw, y_raw, z_raw));
    
        local result = {};
        if (x_raw & 0x8000) {
            result.x <- (-1.0) * _twosComp(x_raw, 0xffff);
        } else {
            result.x <- x_raw;
        }
        
        if (y_raw & 0x8000) {
            result.y <- (-1.0) * _twosComp(y_raw, 0xffff);
        } else {
            result.y <- y_raw;
        }
        
        if (z_raw & 0x8000) {
            result.z <- (-1.0) * _twosComp(z_raw, 0xffff);
        } else {
            result.z <- z_raw;
        }
        
        return result;
    }

}
