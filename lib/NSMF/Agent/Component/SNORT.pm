#
# This file is part of the NSM framework
#
# Copyright (C) 2010-2012, Edward Fjellskål <edwardfjellskaal@gmail.com>
#                          Eduardo Urias    <windkaiser@gmail.com>
#                          Ian Firns        <firnsy@securixlive.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License Version 2 as
# published by the Free Software Foundation.  You may not use, modify or
# distribute this program under any other version of the GNU General
# Public License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
package NSMF::Agent::Component::SNORT;

use warnings;
use strict;
use v5.10;

use base qw(NSMF::Agent::Component);

#
# PERL INCLUDES
#
use Data::Dumper;

#
# NSMF INCLUDES
#
use NSMF::Agent;
use NSMF::Common::Util;

use NSMF::Common::Util;

#
# CONSTATS
#
our $VERSION = {
  major    => 0,
  minor    => 1,
  revision => 0,
  build    => 0,
};


#
# IMPLEMENTATION
#

sub type {
    return 'SNORT';
}

sub sync {
    my $self = shift;

    $self->SUPER::sync();
}

sub run {
    my $self = shift;

    $self->logger->debug('Running snort node...');
}

1;
