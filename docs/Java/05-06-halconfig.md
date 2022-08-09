## HAL Configuration Files **Requires update for Java** {#halconfig}

### devices.json {#devices-json}
**devices.json** provides the interfaces for reading/writing to the employed GAPS devices. Note that different devices can be used in the forward and reverse direction between a pair of enclaves. Device settings for BITW(MIND) on localhost is shown.

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
      "comms":          "tcp",
      "enclave_name_1": "purple_E",
      "listen_addr_1":  "127.0.0.1",
      "listen_port_1":  6789,
      "connect_addr_1": "127.0.0.1",
      "connect_port_1": 6788,
      "enclave_name_2":  "orange_E",
      "listen_addr_2":  "127.0.0.1",
      "listen_port_2":  6788,
      "connect_addr_2": "127.0.0.1",
      "connect_port_2": 6789
    },
    {
      "model":          "sdh_bw_v1",
      "path":           "lo",
      "comms":          "tcp",
      "enclave_name_1": "purple_E",
      "listen_addr_1":  "127.0.0.1",
      "listen_port_1":  6791,
      "connect_addr_1": "127.0.0.1",
      "connect_port_1": 6790,
      "enclave_name_2":  "green_E",
      "listen_addr_2":  "127.0.0.1",
      "listen_port_2":  6790,
      "connect_addr_2": "127.0.0.1",
      "connect_port_2": 6791
    }
  ]
}
```

### xdconf.ini {#xdconf}
**xdconf.ini** is automatically genreated by CodeGenJava. The file appears in the top directory of the desitnation directory (dstDir in config.json). The file includes the [mux, sec, typ](#haltag) mappings for each data type. The data types are oraganized by enclave with from/to enclave clearly specified so the direction is apparent. Appropriate in/out uri interfaces for where the message is read or written  to and from HAL are also specified. xdconf.ini content ultimately populates the map portion of the HAL config file. 
```
{
  "enclaves": [
    {
      "enclave": "green_E",
      "inuri": "ipc:///tmp/tchalsubgreen_e",
      "outuri": "ipc:///tmp/tchalpubgreen_e",
      "halmaps": [
        {
          "from": "purple_E",
          "to": "green_E",
          "mux": 3,
          "sec": 3,
          "typ": 3,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.start.int.java.lang.String"
        },
        {
          "from": "green_E",
          "to": "purple_E",
          "mux": 1,
          "sec": 1,
          "typ": 4,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.start.int.java.lang.String_rsp"
        },
        {
          "from": "purple_E",
          "to": "green_E",
          "mux": 3,
          "sec": 3,
          "typ": 7,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.getRequest"
        },
        {
          "from": "green_E",
          "to": "purple_E",
          "mux": 1,
          "sec": 1,
          "typ": 8,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.getRequest_rsp"
        },
        {
          "from": "purple_E",
          "to": "green_E",
          "mux": 3,
          "sec": 3,
          "typ": 11,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.send.java.lang.String.byte[]"
        },
        {
          "from": "green_E",
          "to": "purple_E",
          "mux": 1,
          "sec": 1,
          "typ": 12,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.send.java.lang.String.byte[]_rsp"
        }
      ]
    },
    {
      "enclave": "purple_E",
      "inuri": "ipc:///tmp/tchalsubpurple_e",
      "outuri": "ipc:///tmp/tchalpubpurple_e",
      "halmaps": [
        {
          "from": "purple_E",
          "to": "orange_E",
          "mux": 4,
          "sec": 4,
          "typ": 1,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.start.int.java.lang.String"
        },
        {
          "from": "orange_E",
          "to": "purple_E",
          "mux": 6,
          "sec": 6,
          "typ": 2,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.start.int.java.lang.String_rsp"
        },
        {
          "from": "purple_E",
          "to": "green_E",
          "mux": 3,
          "sec": 3,
          "typ": 3,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.start.int.java.lang.String"
        },
        {
          "from": "green_E",
          "to": "purple_E",
          "mux": 1,
          "sec": 1,
          "typ": 4,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.start.int.java.lang.String_rsp"
        },
        {
          "from": "purple_E",
          "to": "orange_E",
          "mux": 4,
          "sec": 4,
          "typ": 5,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.getRequest"
        },
        {
          "from": "orange_E",
          "to": "purple_E",
          "mux": 6,
          "sec": 6,
          "typ": 6,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.getRequest_rsp"
        },
        {
          "from": "purple_E",
          "to": "green_E",
          "mux": 3,
          "sec": 3,
          "typ": 7,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.getRequest"
        },
        {
          "from": "green_E",
          "to": "purple_E",
          "mux": 1,
          "sec": 1,
          "typ": 8,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.getRequest_rsp"
        },
        {
          "from": "purple_E",
          "to": "orange_E",
          "mux": 4,
          "sec": 4,
          "typ": 9,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.send.java.lang.String.byte[]"
        },
        {
          "from": "orange_E",
          "to": "purple_E",
          "mux": 6,
          "sec": 6,
          "typ": 10,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.send.java.lang.String.byte[]_rsp"
        },
        {
          "from": "purple_E",
          "to": "green_E",
          "mux": 3,
          "sec": 3,
          "typ": 11,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.send.java.lang.String.byte[]"
        },
        {
          "from": "green_E",
          "to": "purple_E",
          "mux": 1,
          "sec": 1,
          "typ": 12,
          "name": "com.peratonlabs.closure.eop2.level.normal.VideoRequesterNormal.send.java.lang.String.byte[]_rsp"
        }
      ]
    },
    {
      "enclave": "orange_E",
      "inuri": "ipc:///tmp/tchalsuborange_e",
      "outuri": "ipc:///tmp/tchalpuborange_e",
      "halmaps": [
        {
          "from": "purple_E",
          "to": "orange_E",
          "mux": 4,
          "sec": 4,
          "typ": 1,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.start.int.java.lang.String"
        },
        {
          "from": "orange_E",
          "to": "purple_E",
          "mux": 6,
          "sec": 6,
          "typ": 2,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.start.int.java.lang.String_rsp"
        },
        {
          "from": "purple_E",
          "to": "orange_E",
          "mux": 4,
          "sec": 4,
          "typ": 5,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.getRequest"
        },
        {
          "from": "orange_E",
          "to": "purple_E",
          "mux": 6,
          "sec": 6,
          "typ": 6,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.getRequest_rsp"
        },
        {
          "from": "purple_E",
          "to": "orange_E",
          "mux": 4,
          "sec": 4,
          "typ": 9,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.send.java.lang.String.byte[]"
        },
        {
          "from": "orange_E",
          "to": "purple_E",
          "mux": 6,
          "sec": 6,
          "typ": 10,
          "name": "com.peratonlabs.closure.eop2.level.high.VideoRequesterHigh.send.java.lang.String.byte[]_rsp"
        }
      ]
    }
  ]
}
```

### hal_purple configuration {#hal-purple}
The [HAL configuration tool](#halconf) combines the xdconf.ini with selected devices (see closure_env.sh). Example purple enclave configuration for the demo appliaction is shown below.

```
maps =
(
    {
        from_mux = 4;
        to_mux = 4;
        from_sec = 4;
        to_sec = 4;
        from_typ = 1;
        to_typ = 1;
        codec = "NULL";
        to_dev = "xdd1";
        from_dev = "xdd0";
    },
    {
        from_mux = 6;
        to_mux = 6;
        from_sec = 6;
        to_sec = 6;
        from_typ = 2;
        to_typ = 2;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd1";
    },
    {
        from_mux = 3;
        to_mux = 3;
        from_sec = 3;
        to_sec = 3;
        from_typ = 3;
        to_typ = 3;
        codec = "NULL";
        to_dev = "xdd2";
        from_dev = "xdd0";
    },
    {
        from_mux = 1;
        to_mux = 1;
        from_sec = 1;
        to_sec = 1;
        from_typ = 4;
        to_typ = 4;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd2";
    },
    {
        from_mux = 4;
        to_mux = 4;
        from_sec = 4;
        to_sec = 4;
        from_typ = 5;
        to_typ = 5;
        codec = "NULL";
        to_dev = "xdd1";
        from_dev = "xdd0";
    },
    {
        from_mux = 6;
        to_mux = 6;
        from_sec = 6;
        to_sec = 6;
        from_typ = 6;
        to_typ = 6;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd1";
    },
    {
        from_mux = 3;
        to_mux = 3;
        from_sec = 3;
        to_sec = 3;
        from_typ = 7;
        to_typ = 7;
        codec = "NULL";
        to_dev = "xdd2";
        from_dev = "xdd0";
    },
    {
        from_mux = 1;
        to_mux = 1;
        from_sec = 1;
        to_sec = 1;
        from_typ = 8;
        to_typ = 8;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd2";
    },
    {
        from_mux = 4;
        to_mux = 4;
        from_sec = 4;
        to_sec = 4;
        from_typ = 9;
        to_typ = 9;
        codec = "NULL";
        to_dev = "xdd1";
        from_dev = "xdd0";
    },
    {
        from_mux = 6;
        to_mux = 6;
        from_sec = 6;
        to_sec = 6;
        from_typ = 10;
        to_typ = 10;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd1";
    },
    {
        from_mux = 3;
        to_mux = 3;
        from_sec = 3;
        to_sec = 3;
        from_typ = 11;
        to_typ = 11;
        codec = "NULL";
        to_dev = "xdd2";
        from_dev = "xdd0";
    },
    {
        from_mux = 1;
        to_mux = 1;
        from_sec = 1;
        to_sec = 1;
        from_typ = 12;
        to_typ = 12;
        codec = "NULL";
        to_dev = "xdd0";
        from_dev = "xdd2";
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
        addr_in = "ipc:///tmp/tchalpubpurple_e";
        addr_out = "ipc:///tmp/tchalsubpurple_e";
    },
    {
        enabled = 1;
        id = "xdd1";
        path = "lo";
        model = "sdh_bw_v1";
        comms = "tcp";
        addr_in = "127.0.0.1";
        port_in = 6789;
        addr_out = "127.0.0.1";
        port_out = 6788;
    },
    {
        enabled = 1;
        id = "xdd2";
        path = "lo";
        model = "sdh_bw_v1";
        comms = "tcp";
        addr_in = "127.0.0.1";
        port_in = 6791;
        addr_out = "127.0.0.1";
        port_out = 6790;
    }
);

```

