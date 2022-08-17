## HAL Configuration Files {#halconfig}

### `devices.json` {#devices-json}
**`devices.json`** provides the interfaces for reading/writing to the employed GAPS devices. Note that different devices can be used in the forward and reverse direction between a pair of enclaves. Device settings for BITW(MIND), BKND (ILIP), and Emulator shown. 

**Bump-in-the-Wire (MIND device)**
```
{
  "devices": [
    {
      "model":    "sdh_ha_v1",
      "comms":    "zmq",
      "mode_in":  "sub",
      "mode_out": "pub"
    },
    {
      "model":          "sdh_bw_v1",
      "path":           "lo",
      "comms":          "udp",
      "enclave_name_1": "orange",
      "listen_addr_1":  "10.0.0.1",
      "listen_port_1":  6788,
      "enclav_name_2":  "purple",
      "listen_addr_2":  "10.0.1.1",
      "listen_port_2":  6788
    }
  ]
}
```

**Bookends (ILIP Device)**
```
{
  "devices": [
    {
      "model":    "sdh_ha_v1",
      "comms":    "zmq",
      "mode_in":  "sub",
      "mode_out": "pub"
    },
    {
      "model":          "sdh_be_v3",
      "path":           "/dev/gaps_ilip_0_root",
      "comms":          "ilp",
      "enclave_name_1": "green",
      "path_r_1":       "/dev/gaps_ilip_2_read",
      "path_w_1":       "/dev/gaps_ilip_2_write",
      "from_mux_1":     11,
      "init_at_1":      1,
      "enclave_name_2": "orange",
      "path_r_2":       "/dev/gaps_ilip_2_read",
      "path_w_2":       "/dev/gaps_ilip_2_write",
      "from_mux_2":     12,
      "init_at_2":      1
    }
  ]
}
```

**Emulator (socat device)**
```
{
  "devices": [
    {
      "model":    "sdh_ha_v1",
      "comms":    "zmq",
      "mode_in":  "sub",
      "mode_out": "pub"
    },
    {
      "model":    "sdh_socat_v1",
      "path":     "/dev/vcom",
      "comms":    "tty"
    }
  ]
}
```

### `xdconf.ini` {#xdconf}
**`xdconf.ini`** is automatically generated during the automagic stages of the project build by the [rpc generator](#rpc).  The file appears in `partitioned/{single, multi}threaded` directory. The file includes the [mux, sec, typ](#haltag) mappings for each data type. The data types are oraganized by enclave with from/to enclave clearly specified so the direction is apparent. Appropriate in/out uri interfaces for where the message is read or written to and from HAL are also specified. `xdconf.ini` content ultimately populates the map portion of the HAL config file. 
```
{
  "enclaves": [
    {
      "enclave": "orange",
      "inuri": "ipc:///tmp/sock_suborange",
      "outuri": "ipc:///tmp/sock_puborange",
      "halmaps": [
        {
          "from": "purple",
          "to": "orange",
          "mux": 2,
          "sec": 2,
          "typ": 1,
          "name": "nextrpc_purple_orange"
        },
        {
          "from": "orange",
          "to": "purple",
          "mux": 1,
          "sec": 1,
          "typ": 2,
          "name": "okay_purple_orange"
        },
        {
          "from": "purple",
          "to": "orange",
          "mux": 2,
          "sec": 2,
          "typ": 3,
          "name": "request_get_a"
        },
        {
          "from": "orange",
          "to": "purple",
          "mux": 1,
          "sec": 1,
          "typ": 4,
          "name": "response_get_a"
        }
      ]
    },
    {
      "enclave": "purple",
      "inuri": "ipc:///tmp/sock_subpurple",
      "outuri": "ipc:///tmp/sock_pubpurple",
      "halmaps": [
        {
          "from": "purple",
          "to": "orange",
          "mux": 2,
          "sec": 2,
          "typ": 1,
          "name": "nextrpc_purple_orange"
        },
        {
          "from": "orange",
          "to": "purple",
          "mux": 1,
          "sec": 1,
          "typ": 2,
          "name": "okay_purple_orange"
        },
        {
          "from": "purple",
          "to": "orange",
          "mux": 2,
          "sec": 2,
          "typ": 3,
          "name": "request_get_a"
        },
        {
          "from": "orange",
          "to": "purple",
          "mux": 1,
          "sec": 1,
          "typ": 4,
          "name": "response_get_a"
        }
      ]
    }
  ]
}
```

### hal_orange configuration {#hal-orange}
The [HAL configuration tool](#halconf) combines the `xdconf.ini` with selected devices (see closure_env.sh). Example orange enclave configuration for example1 shown below.

```
maps =
(
    {
        from_mux = 2;
        to_mux = 2;
        from_sec = 2;
        to_sec = 2;
        from_typ = 1;
        to_typ = 1;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd1";
    },
    {
        from_mux = 1;
        to_mux = 1;
        from_sec = 1;
        to_sec = 1;
        from_typ = 2;
        to_typ = 2;
        codec = "NULL";
        to_dev = "xdd1";
        from_dev = "xdd0";
    },
    {
        from_mux = 2;
        to_mux = 2;
        from_sec = 2;
        to_sec = 2;
        from_typ = 3;
        to_typ = 3;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd1";
    },
    {
        from_mux = 1;
        to_mux = 1;
        from_sec = 1;
        to_sec = 1;
        from_typ = 4;
        to_typ = 4;
        codec = "NULL";
        to_dev = "xdd1";
        from_dev = "xdd0";
    }
);
devices =
(
    {
        enabled = 1;
        id = "xdd0";
        model = "sdh_ha_v1";
        comms = "zmq";
        mode_in = "sub";
        mode_out = "pub";
        addr_in = "ipc:///tmp/sock_puborange";
        addr_out = "ipc:///tmp/sock_suborange";
    },
    {
        enabled = 1;
        id = "xdd1";
        path = "/dev/vcom";
        model = "sdh_socat_v1";
        comms = "tty";
    }
);
```

