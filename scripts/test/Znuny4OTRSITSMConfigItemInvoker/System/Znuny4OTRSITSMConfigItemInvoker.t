# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

use Kernel::System::ObjectManager;

use Kernel::System::VariableCheck qw(:all);

my $HelperObject                          = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Znuny4OTRSITSMConfigItemInvokerObject = $Kernel::OM->Get('Kernel::System::Znuny4OTRSITSMConfigItemInvoker');

#
# GetConfigItemData()
#
my $ConfigItemData = $Znuny4OTRSITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => 89,
);

1;
