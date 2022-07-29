# --
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::GenericInterface::Event::ObjectType::ITSMConfigItem;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Znuny4OTRSITSMConfigItemInvoker',
);

=head1 NAME

Kernel::GenericInterface::Event::ObjectType::ITSMConfigItem

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub DataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject                             = $Kernel::OM->Get('Kernel::System::Log');
    my $Znuny4OTRSITSMConfigItemInvokerObject = $Kernel::OM->Get('Kernel::System::Znuny4OTRSITSMConfigItemInvoker');

    NEEDED:
    for my $Needed (qw(Data)) {
        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed!"
        );
        return;
    }

    NEEDED:
    for my $Needed (qw(ConfigItemID)) {
        next NEEDED if defined $Param{Data}->{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed in Data!"
        );
        return;
    }

    my $ConfigItemID = $Param{Data}->{ConfigItemID};
    return if !$ConfigItemID;

    my $ConfigItemData = $Znuny4OTRSITSMConfigItemInvokerObject->GetConfigItemData(
        ConfigItemID => $ConfigItemID,
        Event        => $Param{Data}->{Event},
    );
    return if !IsHashRefWithData($ConfigItemData);

    return %{$ConfigItemData};
}

1;
