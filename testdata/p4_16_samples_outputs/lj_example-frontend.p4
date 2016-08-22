#include <core.p4>

extern Checksum16 {
    void clear();
    void update<D>(in D dt);
    void update<D>(in bool condition, in D dt);
    bit<16> get();
}

typedef bit<4> PortId_t;
struct InControl {
    PortId_t inputPort;
}

struct OutControl {
    PortId_t outputPort;
}

parser Parser<H>(packet_in b, out H parsedHeaders);
control MAP<H>(inout H headers, in error parseError, in InControl inCtrl, out OutControl outCtrl);
control Deparser<H>(inout H outputHeaders, packet_out b);
package Simple<H>(Parser<H> p, MAP<H> map, Deparser<H> d);
header ARPA_hdr {
    bit<48> src;
    bit<48> dest;
    bit<16> etype;
}

struct Parsed_rep {
    ARPA_hdr arpa_pak;
}

parser LJparse(packet_in b, out Parsed_rep p) {
    state start {
        b.extract<ARPA_hdr>(p.arpa_pak);
        transition accept;
    }
}

control LjPipe(inout Parsed_rep p, in error parseError, in InControl inCtrl, out OutControl outCtrl) {
    action Drop_action(out PortId_t port) {
        port = 4w0xf;
    }
    action Drop_1() {
        outCtrl.outputPort = 4w0xf;
    }
    action Forward(PortId_t outPort) {
        outCtrl.outputPort = outPort;
    }
    table Enet_lkup() {
        key = {
            p.arpa_pak.dest: exact;
        }
        actions = {
            Drop_action(outCtrl.outputPort);
            Drop_1();
            Forward();
        }
        default_action = Drop_1();
    }
    apply {
        if (p.arpa_pak.isValid()) 
            Enet_lkup.apply();
    }
}

control LJdeparse(inout Parsed_rep p, packet_out b) {
    apply {
        b.emit<ARPA_hdr>(p.arpa_pak);
    }
}

Simple<Parsed_rep>(LJparse(), LjPipe(), LJdeparse()) main;
