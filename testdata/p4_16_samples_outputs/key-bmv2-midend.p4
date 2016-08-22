#include <core.p4>
#include <v1model.p4>

header hdr {
    bit<32> a;
    bit<32> b;
}

struct Headers {
    hdr h;
}

struct Meta {
}

parser p(packet_in b, out Headers h, inout Meta m, inout standard_metadata_t sm) {
    state start {
        b.extract<hdr>(h.h);
        transition accept;
    }
}

control vrfy(in Headers h, inout Meta m, inout standard_metadata_t sm) {
    apply {
    }
}

control update(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    apply {
    }
}

control egress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    apply {
    }
}

control deparser(packet_out b, in Headers h) {
    apply {
        b.emit<hdr>(h.h);
    }
}

control ingress(inout Headers h, inout Meta m, inout standard_metadata_t sm) {
    hdr h_0;
    bit<32> key_0;
    action NoAction_1() {
    }
    @name("c.a") action c_a_0() {
        h_0.b = h_0.a;
    }
    @name("c.t") table c_t() {
        key = {
            key_0: exact @name("e") ;
        }
        actions = {
            c_a_0();
            NoAction_1();
        }
        default_action = NoAction_1();
    }
    action act() {
        h_0 = h.h;
        key_0 = h_0.a + h_0.a;
    }
    action act_0() {
        h.h = h_0;
        sm.egress_spec = 9w0;
    }
    table tbl_act() {
        actions = {
            act();
        }
        const default_action = act();
    }
    table tbl_act_0() {
        actions = {
            act_0();
        }
        const default_action = act_0();
    }
    apply {
        tbl_act.apply();
        c_t.apply();
        tbl_act_0.apply();
    }
}

V1Switch<Headers, Meta>(p(), vrfy(), ingress(), egress(), update(), deparser()) main;
