## Cross-Domain Communications API {#xdcommsapi}

### HAL Data-Plane Client API (send/recv API)

The HAL Data-Plane API abstracts the different hardware APIs used by CDGs, providing a single high-level interace to support all cross-domain communication (xdc) between security enclaves. The client API is available as a library that cross-domain applications can link to. 

The application needs to perform some initialization steps before it can send and receive data.


#### Configure Socket Addresses and Register ADU coders

The HAL architecture will support a multitude of application communication patterns. The current version of HAL implements the 0MQ pub/sub pattern, which has URIs associated with the 0MQ publish and subscribe endpoints bound to the HAL daemon. The application client API provides the following functions to set these endpoint URIs that the HAL daemon is configured with, so that they can be used to send and receive data.

```
extern char *xdc_set_in (char *address);
extern char *xdc_set_out(char *address);
```

Additionally, the application must register (de-)serialization codec functions for all the datatypes that can be sent over the CDG. The [hal/appgen](https://github.com/gaps-closure/hal/tree/develop/appgen) directory will include a number of such codec functions, which are generated from the application. Once registered, the correct codec will be selected and invoked when data is sent or received by HAL.

```
extern void xdc_register(codec_func_ptr encoder, codec_func_ptr decoder, int type);
```

The HAL API supports currently includes codecs to send and receive position and distance information. These codecs are available by linking the application with the appgen/libgma.a (or appgen/libgma.so) library and including [appgen/6month-demo/gma.h](https://github.com/gaps-closure/hal/blob/91eb29f27181589357b76eeb361e23849c70fa62/appgen/6month-demo/gma.h).
```
xdc_register(position_data_encode, position_data_decode, DATA_TYP_POSITION);
xdc_register(distance_data_encode, distance_data_decode, DATA_TYP_DISTANCE);
```
#### Initialize Send and Recv Sockets

The 0MQ pub/sub sockets must be initialized before sending and receiving cross-domain data. The application client API provides the following functions to initialize the sockets:

```
extern void *xdc_ctx(void);
extern void *xdc_pub_socket(void);
extern void *xdc_sub_socket(gaps_tag tag);
extern void *xdc_sub_socket_non_blocking(gaps_tag tag, int timeout);
```

The xdc_ctx() function creates the 0MQ context (returning a pointer to the context). The other functions connect to the  [HAL daemon listening 0MQ sockets](#hal-interfaces), in order to send (on the API pub socket) or receive (on the API sub socket) data. In all cases the HAL-connect functions return a (void *) socket pointer. With the two sub sockets, the user specifies which HAL packets it wants to receive, using the HAL tag as a filter (see below). With the non-blocking sub socket, the user specifies a timeout value (in milliseconds). If the timeout value is -1, then an xdc_recv() call will block until a message is available; else, for all positive timeout values, an xdc_recv() call will wait for a message for that amount of time before returning with -1 value.


#### Send and Recv ADUs {#xdcomms-send-recv}

Once the configuration and socket initialization steps are completed, the application can send and receive data. Since the codecs handle the (de-)serialization, applications can conveniently send and receive data using pointers to in-memory data structures. However, the application must provide the [HAL application tag](#haltag) for the data item to be sent or received.

```
typedef struct _tag {
  uint32_t    mux;      /* APP ID */
  uint32_t    sec;      /* Security tag */
  uint32_t    typ;      /* data type */
} gaps_tag;
```

Although a number of communication patterns are envisioned, currently,  three are supported: a) an asynchronous send, b) a blocking receive (blocks until a message matching the specified tag is received), and c) a receive which supports a timeout (if specified in the xdc_sub_socket_non_blocking() call). These client-side calls are mapped to the pub/sub endpoints that are supported by the HAL daemon.

```
extern void xdc_asyn_send(void *socket, void *adu, gaps_tag *tag);
extern void xdc_blocking_recv(void *socket, void *adu, gaps_tag *tag);
extern int  xdc_recv(void *socket, void *adu, gaps_tag *tag);
```

In additon to the selection of socket (e.g., returned by the xdc_pub_socket() call), the user specifies buffers for the Application Data Unit (adu) and tag. The tag data type (e.g., position or distance) specifies the adu structure (and which registered encode/decode function to use).

In future versions of this API, we plan to support additional send and receive communication patterns including asynchronous receive calls using one-shot or repeated callbacks that can be registered by the application, sending a tagged request and receiving a reply matching the tag, suport for a stream of sequenced messages with in-order delivery, etc.

#### Other API Calls

In addition to the main API configuration and send/receive calls, there are several lower-level calls  available (see [xdcomms.h](https://github.com/gaps-closure/hal/tree/develop/api/xdcomms.h),). There include copying the tag structure and setting the API log level.

```
extern void tag_cp(gaps_tag *tag_out, gaps_tag *tag_in); 
extern void xdc_log_level(int new_level);
```

The log level can be set from level 0 (trace) to level 5 (fatal). The default is level 2 (info), which prints no debug (level 1) or trace (level 0) information.


#### Data API Summary

In summary, the application initializes the URIs for the 0MQ endpoints, registers codecs for the application datatypes, and initializes the send and recv sockets. The applicaiton can then sends and receives data using pointers to in-memory data structures and associated tags. An example python test program that makes uses of this client API can be found in [hal/test/halperf.py](https://github.com/gaps-closure/hal/tree/develop/test/halperf.py), which links to the HAL data-plane client API dynamic library (`libxdcomms.sa`). A C test program that makes use of the recv timeouts can be found in [hal/test/app_req_rep.c](https://github.com/gaps-closure/hal/tree/develop/test/app_req_rep.c), which links to HAL data-plane client API static library (`libxdcomms.a`).

### HAL Control-Plane API (Future)

Eventually we will provide a number of additional API calls to: (i) generate configuration for HAL daemon and the GAPS Devices (CDG) at provision-time; (ii) apply these configurations to HAL and the GAPS Devices. Currently these are configured offline by the system administrator, however, future versions will support auto-generation of CDG configurations, and dynamic provisioning of these configurations into the CDG.