# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::ZnunyITSMConfigItemInvoker;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::GenericInterface::Webservice',
    'Kernel::System::ZnunyHelper',
);

=head1 NAME

var::packagesetup::ZnunyITSMConfigItemInvoker - Installation and/or update code

=head1 SYNOPSIS

All package setup functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::ZnunyITSMConfigItemInvoker');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

    my $Self = {};
    bless( $Self, $Type );

    $ZnunyHelperObject->_RebuildConfig();

    return $Self;
}

=head2 CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    my $ZnunyHelperObject = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

    return if !$Self->_MigrateWebserviceConfigs(%Param);

    return 1;
}

=head2 CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    return if !$Self->CodeInstall(%Param);

    return 1;
}

=head2 CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    return if !$Self->CodeInstall(%Param);

    return 1;
}

=head2 CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

sub _MigrateWebserviceConfigs {
    my ( $Self, %Param ) = @_;

    my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');

    my $Webservices = $WebserviceObject->WebserviceList(
        Valid => 0,
    );
    return 1 if !IsHashRefWithData($Webservices);

    my %InvokerTypeMapping = (
        'Znuny4OTRSITSMConfigItemInvoker::Generic' => 'ITSMConfigItemInvoker::Generic',
    );

    WEBSERVICEID:
    for my $WebserviceID ( sort keys %{$Webservices} ) {
        my $WebserviceData = $WebserviceObject->WebserviceGet(
            ID => $WebserviceID,
        );
        next WEBSERVICEID if !IsHashRefWithData($WebserviceData);

        my $InvokerConfigs   = $WebserviceData->{Config}->{Requester}->{Invoker};
        my $OperationConfigs = $WebserviceData->{Config}->{Provider}->{Operation};

        # Migrate web service invoker types.
        if ( IsHashRefWithData($InvokerConfigs) ) {
            INVOKER:
            for my $Invoker ( sort keys %{$InvokerConfigs} ) {
                my $InvokerConfig = $InvokerConfigs->{$Invoker};
                next INVOKER if !defined $InvokerConfig->{Type};
                next INVOKER if !exists $InvokerTypeMapping{ $InvokerConfig->{Type} };

                $InvokerConfig->{Type} = $InvokerTypeMapping{ $InvokerConfig->{Type} };
            }
        }

        $WebserviceObject->WebserviceUpdate(
            ID      => $WebserviceID,
            Name    => $WebserviceData->{Name},
            Config  => $WebserviceData->{Config},
            ValidID => $WebserviceData->{ValidID},
            UserID  => 1,
        );
    }

    return 1;
}

1;
