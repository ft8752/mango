#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Products::Path;
Mango::Tests::Catalyst::Products::Path->runtests;
