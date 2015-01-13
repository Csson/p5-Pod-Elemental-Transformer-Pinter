use 5.14.1;
use strict;

use Moops;

class SplintTestAttributes using Moose {

    method a_test_method(Int $thing   does doc('The first argument'),
                         Bool :$maybe does doc("If necessary\nmethoddoc|Just a test")
                     --> Str          does doc('In the future')
    ) {
        return 'woo';
    }

}

__END__

=pod

=encoding utf-8

:splint classname SplintTestAttributes

:splint method a_test_method
