# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Znuny4OTRSITSMConfigItemInvoker;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Log',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::System::Znuny4OTRSITSMConfigItemInvoker

=head1 PUBLIC INTERFACE

=head2 new()

    Don't use the constructor directly, use the ObjectManager instead:

    my $Znuny4OTRSITSMConfigItemInvokerObject = $Kernel::OM->Get('Kernel::System::Znuny4OTRSITSMConfigItemInvoker');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 GetConfigItemData()

    Returns hash with complete data of config item with given ID.

    my $ConfigItemData = $Znuny4OTRSITSMConfigItemInvokerObject->GetConfigItemData(
        ConfigItemID => 21,

        IncludePreviousVersion => 1, # defaults to 0; returns also data of previous version, if available
    );

=cut

sub GetConfigItemData {
    my ( $Self, %Param ) = @_;

    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    NEEDED:
    for my $Needed (qw(ConfigItemID)) {
        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $CurrentConfigItemVersion = $ConfigItemObject->VersionGet(
        ConfigItemID => $Param{ConfigItemID},
        XMLDataGet   => 1,
    );
    return if !IsHashRefWithData($CurrentConfigItemVersion);

    my %ConfigItemData;
    $ConfigItemData{XMLData} ||= {};
    if ( IsHashRefWithData( $CurrentConfigItemVersion->{XMLData}->[1]->{Version}->[1] ) ) {
        $Self->_XML2Data(
            Result     => $ConfigItemData{XMLData},
            Data       => $CurrentConfigItemVersion->{XMLData}->[1]->{Version}->[1],
            Definition => $CurrentConfigItemVersion->{XMLDefinition},
        );
    }

    for my $Field (qw(ConfigItemID Name ClassID Class DefinitionID DeplStateID DeplState InciStateID InciState)) {
        $ConfigItemData{$Field} = $CurrentConfigItemVersion->{$Field};
    }

    return \%ConfigItemData;

    #     my $ConfigItemVersions = $ConfigItemObject->VersionList(
    #         ConfigItemID => $Param{ConfigItemID},
    #     );

    #     return;
}

=head2 _XML2Data()

    Turns XML into Perl structure.

    my $Success = $Znuny4OTRSITSMConfigItemInvokerObject->_XML2Data(
        Parent          => $Identifier,          # optional: contains the field name of the parent XML
        Result          => $Result,              # contains the reference to the result hash
        Data            => $Data{$Field}->[1],   # contains the XML hash to be parsed
    );

    Returns true value on success.

=cut

sub _XML2Data {
    my ( $Self, %Param ) = @_;

    my $Result = $Param{Result};
    my $Parent = $Param{Parent} || '';
    my %Data   = %{ $Param{Data} || {} };

    FIELD:
    for my $Field ( sort keys %Data ) {
        next FIELD if !IsArrayRefWithData( $Data{$Field} );

        my $FieldDefinitionIndex = 0;
        my $FieldType;

        #         my $Class;

        FIELDDEFINITION:
        for my $FieldDefinition ( @{ $Param{Definition} // [] } ) {
            if ( defined $FieldDefinition->{Key} && $FieldDefinition->{Key} eq $Field ) {
                $FieldType = $FieldDefinition->{Input}->{Type};

                #                 $Class     = $FieldDefinition->{Input}->{Class};
                last FIELDDEFINITION;
            }

            $FieldDefinitionIndex++;
        }

        $Result->{$Field} = [];

        for my $Index ( 1 .. $#{ $Data{$Field} } ) {
            my $Value = $Data{$Field}->[$Index]->{Content};

            my $CurrentResult = {};

            my $Definition = $Param{Definition}->[$FieldDefinitionIndex]->{Sub} // [];

            $Self->_XML2Data(
                %Param,
                Parent     => $Field,
                Result     => $CurrentResult,
                Data       => $Data{$Field}->[$Index],
                Definition => $Definition,
            );

            if ( defined $Value ) {
                $CurrentResult->{Content} = $Value;

                my $ReadableValue = $Self->_GetReadableValue(
                    Value     => $Value,
                    FieldType => $FieldType,

                    #                         Class     => $Class,
                );

                if ( $ReadableValue ne $Value ) {
                    $CurrentResult->{ReadableValue} = $ReadableValue;
                }

                if ( keys %{$CurrentResult} ) {
                    push @{ $Result->{$Field} }, $CurrentResult;
                }
            }
        }
    }

    return 1;
}

=head2 _GetReadableValue()

    Maps value of certain field types (ID) to a value that can be read (name, text, etc.).

    my $ReadableValue = $Znuny4OTRSITSMConfigItemInvokerObject->_GetReadableValue(
        Value     => 4,
        FieldType => 'GeneralCatalog',
    );

    Returns the readable value depending on the field type or the original value
    if no readable value could be determined.

=cut

sub _GetReadableValue {
    my ( $Self, %Param ) = @_;

    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    my $Value = $Param{Value};

    return $Value if !defined $Param{Value};
    return $Value if !length $Param{Value};

    return $Value if !defined $Param{FieldType};
    return $Value if !length $Param{FieldType};

    #     return $Value if !defined $Param{Class};
    #     return $Value if !length $Param{Class};

    my $ReadableValue = $Value;

    if ( $Param{FieldType} eq 'GeneralCatalog' ) {
        my $GeneralCatalogItemData = $GeneralCatalogObject->ItemGet(
            ItemID => $Value,
        );
        return $Value if !IsHashRefWithData($GeneralCatalogItemData);
        return $Value if !defined $GeneralCatalogItemData->{Name};

        $ReadableValue = $GeneralCatalogItemData->{Name};
    }

    return $ReadableValue;
}

1;
