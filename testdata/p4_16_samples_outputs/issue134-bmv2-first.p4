#include <core.p4>
#include <v1model.p4>

header ipv4_t {
    bit<4>  ihl;
    bit<16> hdrChecksum;
}

struct H {
    ipv4_t ipv4;
}

struct M {
}

parser ParserI(packet_in pk, out H hdr, inout M meta, inout standard_metadata_t smeta) {
    state start {
        transition accept;
    }
}

control IngressI(inout H hdr, inout M meta, inout standard_metadata_t smeta) {
    apply {
    }
}

control EgressI(inout H hdr, inout M meta, inout standard_metadata_t smeta) {
    apply {
    }
}

control DeparserI(packet_out pk, in H hdr) {
    apply {
    }
}

control VerifyChecksumI(in H hdr, inout M meta) {
    apply {
    }
}

control ComputeChecksumI(inout H hdr, inout M meta) {
    Checksum16() c16;
    apply {
        if (hdr.ipv4.ihl == 4w5) 
            hdr.ipv4.hdrChecksum = c16.get<tuple<bit<1>>>({ 1w0 });
    }
}

V1Switch<H, M>(ParserI(), VerifyChecksumI(), IngressI(), EgressI(), ComputeChecksumI(), DeparserI()) main;
