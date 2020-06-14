#!/system/bin/sh

# Copyright (C) 2020 EpicHook (yuhan@rsyhan.me)

if [[ "$(settings get secure user_setup_complete)" != "1" ]]; then
    # Reset SIM Manager
    settings put global multi_sim_data_call 1
    settings put global mobile_data1 1
    settings reset global com.android.dialer_simCardsState
fi
