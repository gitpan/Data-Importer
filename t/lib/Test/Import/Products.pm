#
# This file is part of Data-Importer
#
# This software is copyright (c) 2014 by Kaare Rasmussen.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package Test::Import::Products;

use 5.010;
use namespace::autoclean;
use Moose;
use MooseX::Traits;

extends 'Data::Importer';

=head1 ATTRIBUTES

=head2 products

An arrayref w/ the products to be inserted / updated

=cut

has 'products' => (
	is => 'ro',
	isa => 'ArrayRef',
	traits => [qw/Array/],
	handles => {
		add_product => 'push',
	},
	default => sub { [] },
);

=head1 METHODS

=head2 handle_row

Validates input

Called for each row in the input file

=cut

sub handle_row {
	my ($self, $row, $lineno) = @_;
	#product
	my %prow = ( %$row );
	$self->add_product(\%prow);
}

=head2 import_transaction

Performs the actual database update

=cut

sub import_transaction {
	my $self = shift;
	my $schema = $self->schema;
	for my $product (@{ $self->products }) {
		next unless $product->{item_name};

		my $data = {
			name => $product->{item_name},
			ingredients => $product->{ingredients},
			qty => $product->{qty},
		};
		$schema->resultset('Product')->create($data) or die;
	}
}

__PACKAGE__->meta->make_immutable;

#
# This file is part of Data-Importer
#
# This software is copyright (c) 2014 by Kaare Rasmussen.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#

__END__
