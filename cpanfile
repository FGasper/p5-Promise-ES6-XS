# This cpanfile is purely for CI testing and not meant to be used
# to produce dynamic deps for your Makefile.PL
requires 'XSLoader' => 0;
requires 'AnyEvent' => 0;

on "test" => sub {
   requires 'Test::More' => 0;
   requires 'Test::Deep' => 0;
   requires 'Test::FailWarnings' => 0;
   requires 'File::Temp' => 0;
   requires 'Mojo::IOLoop' => 0 if $] >= '5.016';
   requires 'Mojolicious' => 0 if $] >= '5.016';
   requires 'IO::Async::Loop' => 0 if $] >= '5.010';
};
