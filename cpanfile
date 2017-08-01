requires "Carp" => "0";
requires "Exporter" => "0";
requires "Module::Runtime" => "0";
requires "Moose" => "0";
requires "Moose::Role" => "0";
requires "Moose::Util" => "0";
requires "Moose::Util::TypeConstraints" => "0";
requires "MooseX::Clone" => "0.05";
requires "MooseX::Params::Validate" => "0.14";
requires "Scalar::Util" => "0";
requires "Try::Tiny" => "0";
requires "overload" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "FindBin" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::Fatal" => "0";
  requires "Test::Moose" => "0";
  requires "Test::More" => "0";
  requires "Test::Requires" => "0";
  requires "perl" => "5.006";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Test::More" => "0.96";
  requires "Test::Vars" => "0";
};
