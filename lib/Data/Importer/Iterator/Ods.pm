#
# This file is part of Data-Importer
#
# This software is copyright (c) 2014 by Kaare Rasmussen.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package Data::Importer::Iterator::Ods;
$Data::Importer::Iterator::Ods::VERSION = '0.003';
use 5.010;
use namespace::autoclean;
use Moose;
use Spreadsheet::Read qw/ReadData row/;

extends 'Data::Importer::Iterator';

=head1 Description

Subclass for handling the import of an ods file

=head1 ATTRIBUTES

=head2 ods

The ods object

=cut

has 'ods' => (
	is => 'ro',
	lazy_build => 1,
);

=head2 sheet

The sheet name or number

=cut

has sheet => (
	is => 'ro',
	isa => 'Int',
	default => 1,
);

=head1 "PRIVATE" ATTRIBUTES

=head2 column_names

The column names

=cut

has column_names => (
	is => 'rw',
	isa => 'ArrayRef',
	predicate => 'has_column_names',
);

=head1 METHODS

=head2 _build_ods

The lazy builder for the ods object

=cut

sub _build_ods {
	my $self = shift;
	my $ods = ReadData($self->file_name);
	return $ods;
}

=head2 next

Return the next row of data from the file

=cut

sub next {
	my $self = shift;
	my $ods = $self->ods;
	$self->inc_lineno;
	# Use the first row as column names:
	if (!$self->has_column_names) {
		my @fieldnames = map {my $header = lc $_; $header =~ tr/ /_/; $header} row($ods->[$self->sheet], $self->lineno);
		die "Only one column detected, please use comma ',' to separate data." if @fieldnames < 2;

		$self->column_names(\@fieldnames);
	}
	my $columns = $self->column_names;
	my $colno = 0;
	my @cells = row($ods->[$self->sheet], $self->lineno);
	return unless grep { $_ } @cells;
    return { map { $columns->[$colno++] => $_ } @cells };
}

1;

#
# This file is part of Data-Importer
#
# This software is copyright (c) 2014 by Kaare Rasmussen.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
