# $Id$
package Mango::Profile;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;
};
__PACKAGE__->mk_group_accessors('column', qw/first_name last_name created/);

1;
