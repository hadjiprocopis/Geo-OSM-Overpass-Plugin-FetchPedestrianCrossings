#!/usr/bin/env perl

use strict;
use warnings;

use lib 'blib/lib';

use Test::More;

use Geo::OSM::Overpass;
use Geo::OSM::Overpass::Plugin::FetchPedestrianCrossings;
use Geo::BoundingBox;

my $num_tests = 0;

my $bbox = Geo::BoundingBox->new();
ok(defined $bbox && 'Geo::BoundingBox' eq ref $bbox, 'Geo::BoundingBox->new()'.": called") or BAIL_OUT('Geo::BoundingBox->new()'.": failed, can not continue."); $num_tests++;
# this is LAT,LON convention
ok(1 == $bbox->bounded_by(
	[ 35.157610, 33.339986, 35.157771, 33.340864]
), 'bbox->bounded_by()'." : called"); $num_tests++;

my $eng = Geo::OSM::Overpass->new();
ok(defined $eng && 'Geo::OSM::Overpass' eq ref $eng, 'Geo::OSM::Overpass->new()'.": called") or BAIL_OUT('Geo::OSM::Overpass->new()'.": failed, can not continue."); $num_tests++;
$eng->verbosity(2);
ok(defined $eng->bbox($bbox), "bbox() called"); $num_tests++;

my $plug = Geo::OSM::Overpass::Plugin::FetchPedestrianCrossings->new({
	'engine' => $eng
});
ok(defined($plug) && 'Geo::OSM::Overpass::Plugin::FetchPedestrianCrossings' eq ref $plug, 'Geo::OSM::Overpass::Plugin::FetchPedestrianCrossings->new()'." : called"); $num_tests++;

ok(defined $plug->gorun(), "checking gorun()"); $num_tests++;

my $result = $eng->last_query_result();
ok(defined $result, "checking if got result"); $num_tests++;
# saturn operator, see https://perlmonks.org/?node_id=11100099
ok(defined($result) && 2 == ( ()= $$result =~ m|<node.+?id="|gs), "checking result contains exactly two nodes."); $num_tests++;
ok(defined($result) && 1 == ( ()= $$result =~ m|<node.+?id="4219339742".+?>.*?<tag.+?v="crossing".+?>|gs), "checking result contains specified node #1."); $num_tests++;
ok(defined($result) && 1 == ( ()= $$result =~ m|<node.+?id="4219339748".+?>.*?<tag.+?v="crossing".+?>|gs), "checking result contains specified node #1."); $num_tests++;

# END
done_testing($num_tests);
