use v6.e.PREVIEW;
unit class Vikna::Object;

use Vikna::X;

my class CodeFlow {
    has UInt $.id;
    has Str:D $.name is rw = "*anon*";
    has Promise $.promise is rw;
}

has $.app;

multi method throw(X::Base:D $ex) {
    $ex.rethrow
}

multi method throw( X::Base:U \exception, *%args ) {
    exception.new( :obj(self), |%args ).throw
}

multi method fail( X::Base:D $ex ) {
    fail $ex
}

multi method fail( X::Base:U \exception, *%args ) {
    fail exception.new( :obj(self), |%args )
}

multi method create(Mu \type, |c) {
    with $!app {
        .create: type, :$!app, |c
    }
    else {
        type.new: |c
    }
}

method trace(|c) {
    with $!app {
        .trace: :obj(self), |c
    }
}

my @flows;
my Lock:D $flow-lock .= new;
method allocate-flow(Str :$name?) {
    $flow-lock.protect: {
        my $id;
        for ^Inf {
            unless @flows[$_].defined {
                $id = $_;
                last
            }
        }
        @flows[$id] = CodeFlow.new: :$id, :$name;
    }
}

method free-flow(CodeFlow:D $flow) {
    $flow-lock.protect: {
        @flows[$flow.id]:delete
    }
}

method flow(&code, Str :$name?, :$sync = False) {
    my $flow = $.allocate-flow(:$name);

    sub flow-start {
        my $*VIKNA-FLOW = $flow;
        LEAVE $.free-flow($flow);
        &code();
    }

    if $sync {
        Promise.kept(flow-start);
    }
    else {
        ( $flow.promise = Promise.start(&flow-start) ).then: {
            if .status ~~ Broken {
                $.trace: ~ .cause, :error;
                note "===SORRY!=== Flow `$name` exploded with:\n", .cause, .cause.backtrace;
                exit 1;
            }
        };
    }
}