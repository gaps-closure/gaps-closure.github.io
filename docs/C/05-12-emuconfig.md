## EMU configuration **Review: Ben** 

### enclaves.json
Configuration file that specifies the cross-doamin elments of the scenario nodes and associated topology. Example1 enclaves.json shown below. Key elements include:

- qname: scenario name
- enclave: the enclave, set of nodes running at the same level
- xdhost: cross-domain host, node from enclave with access to the guard
- inthost: internal enclave node (future use)
- halconf: HAL configuration file that should be used to run HAL automatically on xdhost node
- xdgateway: specifies node between the enclaves, used to manage cross-domain communication and filters in BITW config
- xdlink: configures the cross domain link between xdhost and xdgateway, BITW or BKND specified for guard type

```
{
  "qname": "example1",
  "enclave": 
  [
    {
      "qname": "orange",
      "xdhost":
      [
	{
          "hostname": "orange-enclave-gw-P",
	  "halconf": "example1_hal_orange.cfg",
	  "hwconf":{"arch": "amd64"},
	  "swconf":{"os": "ubuntu", "distro": "focal", "kernel": "focal",
		    "service": [{"s": "UserDefined"}]
	  }, 
	  "nwconf":{"interface": 
		    [{"ifname" :"eth0", "addr":"10.0.101.1/24"},
 		     {"ifname" :"eth1", "addr":"10.1.2.2/24"}] },
	  "ifpeer":[{"ifname": "eth0", "peername": "orange-hub"},
	            {"ifname": "eth1", "peername": "orange-purple-xd-gw"}]
	}
      ],
      "inthost":
      [
	{
	  "hostname": "orange-1",
	  "swconf":{"service": [{"s": "UserDefined"}]},
	  "nwconf":{"interface":
		    [{"ifname": "eth0", "addr": "10.0.101.2/24"}] },
          "ifpeer":[{"ifname": "eth0", "peername": "orange-hub"}]
	},
	{
	  "hostname": "orange-2",
	  "swconf":{"service": [{"s": "UserDefined"}]},
	  "nwconf":{"interface":
		    [{"ifname": "eth0", "addr": "10.0.101.3/24"}] },
	  "ifpeer":[{"ifname": "eth0", "peername": "orange-hub"}]
	}
      ],
      "link": 
      [
	{"f": "orange-hub", "t":"orange-1", "bandwidth": "100000000", "delay": 0},
        {"f": "orange-hub", "t":"orange-2", "bandwidth": "100000000", "delay": 0},
        {"f": "orange-hub", "t":"orange-enclave-gw-P", "bandwidth": "100000000", "delay": 0} 
      ],
      "hub": 
      [
	{ "hostname": "orange-hub", 
	  "ifpeer": [{"ifname": "e0", "peername": "orange-enclave-gw-P"},
		     {"ifname": "e1", "peername": "orange-1"},
		     {"ifname": "e2", "peername": "orange-2"}]
	}
      ]
    },
    {
      "qname": "purple",
      "xdhost":
      [
	{
	  "hostname": "purple-enclave-gw-O",
	  "halconf": "example1_hal_purple.cfg",
	  "hwconf":{"arch": "amd64"},
	  "swconf":{"os": "ubuntu", "distro": "focal", "kernel": "focal",
		    "service": [{"s": "UserDefined"}]}, 
	  "nwconf":{"interface": 
		    [{"ifname" :"eth0", "addr":"10.0.102.1/24"},
 		     {"ifname" :"eth1", "addr":"10.2.1.2/24"}] },
	  "ifpeer":[{"ifname": "eth0", "peername": "purple-hub"},
	            {"ifname": "eth1", "peername": "orange-purple-xd-gw"}]
	}
      ],
      "inthost":
      [
	{
	  "hostname": "purple-1",
	  "swconf":{"service": [{"s": "UserDefined"}]},
	  "nwconf":{"interface":
		    [{"ifname": "eth0", "addr": "10.0.102.2/24"}] },
	  "ifpeer":[{"ifname": "eth0", "peername": "purple-hub"}]
	},
	{
	  "hostname": "purple-2",
	  "swconf":{"service": [{"s": "UserDefined"}]},
	  "nwconf":{"interface":
		    [{"ifname": "eth0", "addr": "10.0.102.3/24"}] },
	  "ifpeer":[{"ifname": "eth0", "peername": "purple-hub"}]
	}
      ],
      "link": 
      [
	{"f": "purple-hub", "t":"purple-1", "bandwidth": "100000000", "delay": 0}, 
        {"f": "purple-hub", "t":"purple-2", "bandwidth": "100000000", "delay": 0}, 
        {"f": "purple-hub", "t":"purple-enclave-gw-O", "bandwidth": "100000000", "delay": 0} 
      ],
      "hub": 
      [
	{ "hostname": "purple-hub", 
	  "ifpeer": [{"ifname": "e0", "peername": "purple-enclave-gw-O"},
		     {"ifname": "e1", "peername": "purple-1"},
		     {"ifname": "e2", "peername": "purple-2"}]
	}
      ]
    }
  ],
  "xdgateway":
  [
    {
      "hostname": "orange-purple-xd-gw",
      "swconf":{"service": [{"s": "UserDefined"}, {"s": "IPForward"}]},
      "nwconf":{"interface":
		[{"ifname": "eth0", "addr": "10.1.2.1/24"},
		 {"ifname": "eth1", "addr": "10.2.1.1/24"}] },
      "ifpeer":[{"ifname": "eth0", "peername": "orange-enclave-gw-P"},
		{"ifname": "eth1", "peername": "purple-enclave-gw-O"}]
    }
  ],
  "xdlink": 
  [
    { "model":  "BKND",
      "left":   {"f": "orange-enclave-gw-P", "t":"orange-purple-xd-gw",
	         "egress":   {"filterspec": "left-egress-spec", "bandwidth":"100000000", "delay": 0},
                 "ingress":  {"filterspec": "left-ingress-spec", "bandwidth":"100000000", "delay": 0}},
      "right":  {"f": "orange-purple-xd-gw", "t":"purple-enclave-gw-O",
	         "egress":   {"filterspec": "right-egress-spec", "bandwidth":"100000000", "delay": 0},
                 "ingress":   {"filterspec": "right-ingress-spec", "bandwidth":"100000000", "delay": 0}}
    }
  ]
}
```
### layout.json
Controls the artistic layout of the scenario elements (nodes, links, colors). Use [2,3,4]enclave directories for boiler plate layouts depending on the network size required for additional scenarios.

```
{
 "canvas": { "name": "Canvas1" },
 "option": {
  "optglobal": {
   "interface_names": "no",
   "ip_addresses": "no",
   "ipv6_addresses": "no",
   "node_labels": "yes",
   "link_labels": "no",
   "show_api": "no",
   "background_images": "no",
   "annotations": "yes",
   "grid": "yes",
   "traffic_start": "0"
  },
  "session": {}
 },
 "nodelayout": [
  {
   "hostname":"orange-enclave-gw-P",
   "canvas":"Canvas1",
   "iconcoords": {"x":265.0, "y":171.0},
   "labelcoords": {"x":265.0, "y":203.0}
  },
  {
   "hostname":"purple-enclave-gw-O",
   "canvas":"Canvas1",
   "iconcoords": {"x":697.0, "y":168.0},
   "labelcoords": {"x":697.0, "y":200.0}
  },
  {
   "hostname":"orange-1",
   "canvas":"Canvas1",
   "iconcoords": {"x":122.0, "y":74.0},
   "labelcoords": {"x":122.0, "y":106.0}
  },
  {
   "hostname":"orange-2",
   "canvas":"Canvas1",
   "iconcoords": {"x":121.0, "y":265.0},
   "labelcoords": {"x":121.0, "y":297.0}
  },
  {
   "hostname":"purple-1",
   "canvas":"Canvas1",
   "iconcoords": {"x":837.0, "y":72.0},
   "labelcoords": {"x":837.0, "y":104.0}
  },
  {
   "hostname":"purple-2",
   "canvas":"Canvas1",
   "iconcoords": {"x":839.0, "y":268.0},
   "labelcoords": {"x":839.0, "y":300.0}
  },
  {
   "hostname":"orange-hub",
   "canvas":"Canvas1",
   "iconcoords": {"x":121.0, "y":171.0},
   "labelcoords": {"x":121.0, "y":195.0}
  },
  {
   "hostname":"purple-hub",
   "canvas":"Canvas1",
   "iconcoords": {"x":838.0, "y":167.0},
   "labelcoords": {"x":838.0, "y":191.0}
  },
  {
   "hostname":"orange-purple-xd-gw",
   "canvas":"Canvas1",
   "iconcoords": {"x":483.0, "y":169.0},
   "labelcoords": {"x":483.0, "y":201.0}
  }
 ],
 "annotation": [
  {
    "bbox": {"x1":56.0, "y1": 36.0, "x2": 399.0, "y2": 322.0},
    "type": "rectangle",
    "label": "OrangeEnclave",
    "labelcolor": "black",
    "fontfamily": "Arial",
    "fontsize": 12,
    "color": "#ff8c00",
    "width": 0,
    "border": "black",
    "rad": 25,
    "canvas": "Canvas1"
  },
  {
    "bbox": {"x1":607.0, "y1": 41.0, "x2": 918.0, "y2": 327.0},
    "type": "rectangle",
    "label": "PurpleEnclave",
    "labelcolor": "black",
    "fontfamily": "Arial",
    "fontsize": 12,
    "color": "#c300ff",
    "width": 0,
    "border": "black",
    "rad": 25,
    "canvas": "Canvas1"
  }
 ]
}
```

### settings.json
Controls general settings for the emulator.

- core_timeout: if CORE does not start in specified number of seconds, emulator will quit. Make sure core-daemon is properly installed
- instdir: parent directory where emu is installed
- imgdir: directory where QEMU golden images are stored
- mgmt_ip: IP of VMs for ssh purposes
- shadow_directories: comma separated list of directories to be mounted uniquely in CORE BSD containers
- snapdir: location of VM snapshots relative to ${instdir}/emu
- imndir: location of scenario CORE .imn files relative to ${instdir}/emu

```
{
  "core_timeout": 30,
  "instdir": "/opt/closure",
  "imgdir": "/IMAGES",
  "mgmt_ip": "10.200.0.1",
  "shadow_directories": "/root;",
  "snapdir": ".snapshots",
  "imndir": ".imnfiles"
}
```