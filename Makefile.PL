use ExtUtils::MakeMaker;
WriteMakefile
  (NAME            => 'Algorithm::LUHN',
   VERSION_FROM    => 'LUHN.pm',
   PREREQ_PM       => {Test => 0},
   dist =>
   {COMPRESS       => 'gzip',
    SUFFIX         => 'gz',
   },

   clean           => {FILES => ".test*"},
  );
