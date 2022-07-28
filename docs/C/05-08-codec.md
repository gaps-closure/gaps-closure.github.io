## Serialization CODECs

Below is a codec.c that is generated from the [`rpc_generator`](#rpc) 
during autogeneration. The codec contains a print, encode and decode
function for each request and response. This codec.c is taken from example1, so
the relevant functions will be for `get_a` and the functions shown are for
the `get_a` request. (Note: the corresponding response functions are omitted). 

```c
// ...

void request_get_a_print (request_get_a_datatype *request_get_a) {
  fprintf(stderr, "request_get_a(len=%ld): ", sizeof(*request_get_a));
  fprintf(stderr, " %d,", request_get_a->dummy);
  fprintf(stderr, " %u, %u, %u, %hu, %hu\n",
          request_get_a->trailer.seq,
          request_get_a->trailer.rqr,
          request_get_a->trailer.oid,
          request_get_a->trailer.mid,
          request_get_a->trailer.crc);
}

void request_get_a_data_encode (void *buff_out, void *buff_in, size_t *len_out) {
  request_get_a_datatype *p1 = (request_get_a_datatype *) buff_in;
  request_get_a_output   *p2 = (request_get_a_output *)   buff_out;
  p2->dummy = htonl(p1->dummy);
  p2->trailer.seq = htonl(p1->trailer.seq);
  p2->trailer.rqr = htonl(p1->trailer.rqr);
  p2->trailer.oid = htonl(p1->trailer.oid);
  p2->trailer.mid = htons(p1->trailer.mid);
  p2->trailer.crc = htons(p1->trailer.crc);
  *len_out = sizeof(int32_t) + sizeof(trailer_datatype);
}

void request_get_a_data_decode (void *buff_out, void *buff_in, size_t *len_in) {
  request_get_a_output   *p1 = (request_get_a_output *)   buff_in;
  request_get_a_datatype *p2 = (request_get_a_datatype *) buff_out;
  p2->dummy = ntohl(p1->dummy);
  p2->trailer.seq = ntohl(p1->trailer.seq);
  p2->trailer.rqr = ntohl(p1->trailer.rqr);
  p2->trailer.oid = ntohl(p1->trailer.oid);
  p2->trailer.mid = ntohs(p1->trailer.mid);
  p2->trailer.crc = ntohs(p1->trailer.crc);
}

// ...
```
