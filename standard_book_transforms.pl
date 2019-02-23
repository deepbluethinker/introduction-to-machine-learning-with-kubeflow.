#!/usr/bin/perl
use strict;
use warnings;
use File::Slurp;

sub process_file {
    my $file = shift @_;
    my $text = read_file( $file );
    # Transform the text
    $text =~ s/to\s+spark/to Spark/gi;
    $text =~ s/itsself/itself/gi;
    $text =~ s/zipcode/zip code/gi;
    $text =~ s/its self/itself/gi;
    $text =~ s/([\s\n\,]+)scala([\s\n\,]+)/$1Scala$2/gi;
    $text =~ s/([\s\n\,]+)java([\s\n\,]+)/$1Java$2/gi;
    $text =~ s/zookeeper/ZooKeeper/gi;
    $text =~ s/[sS]park([\s\n]+)[cC]ontext/Spark$1Context/gi;
    $text =~ s/hive([\s\n]+)support/Hive$1support/gi;
    $text =~ s/spark[\s\n]+streaming/Spark Streaming/gi;
    $text =~ s/built[\s\n]+in/built-in/gi;
    #$text =~ s/data[\s\n]+scientists[\s\n]+and[\s\n]+engineers/Data Scientists and Engineers/gi;
    $text =~ s/([\s\n])rdd([\s\n\.])/$1RDD$2/gi;
    $text =~ s/its[\s\n]important/it's important/gi;
    $text =~ s/its[\s\n]time/it's time/gi;
    $text =~ s/its[\s\n]most often/it's most often/gi;
    $text =~ s/our selves/ourselves/gi;
    $text =~ s/can not/cannot/gi;
    $text =~ s/tupple/tuple/gi;
    $text =~ s/compatable/compatible/gi;
    $text =~ s/hive metastore/Hive Metastore/gi;
    $text =~ s/with out/without/gi;
    $text =~ s/Scala\.(\w)/scala.$1/gi;
    $text =~ s/Java\.(\w)/java.$1/gi;
    $text =~ s/(\w[\.]+)SQL([\s\.]+)/$1sql$2/gi;
    $text =~ s/([\s\n]+)the[\s\n]+the([\s\n\.]+)/$1the$2/gi;
    $text =~ s/([\s\n`]+)sql([\s\n\.`]+)/$1SQL$2/gi;
    $text =~ s/([\s\n]+)twitter([\s\n\.]+)/$1Twitter$2/gi;
    # Undo the caps for source names in the [source, ] blocks
    $text =~ s/\[source, [Ss]cala\s+\]/[source, scala]/gi;
    $text =~ s/\[source, [Jj]ava\s+\]/[source, java]/gi;
    $text =~ s/([Ee])cho [Ss]ystem/$1cho system/gi;
    #Done
    $text =~ s/(c)hallanging/$1hallenging/gi;
    $text =~ s/corse/coarse/gi;
    $text =~ s/footenote/footnote/gi;
    $text =~ s/(\s+[Aa])ss(\s+)/$1s$2/gi;
    $text =~ s/so that so that/so that/gi;
    $text =~ s/\$\$link:/link:\$\$/gi;
    $text =~ s/([\s\n`]+)hive([\s\n`]+)/$1Hive$2/gi;
    $text =~ s/([\s\n`]+)sqlcontext([\s\n`]+)/$1SQLContext$2/gi;
    $text =~ s/([\s\n`]+)hivecontext([\s\n`]+)/$1HiveContext$2/gi;
    $text =~ s/([\s\n]+)sqlcontext([\s\n\.]+)/$1SQLContext$2/gi;
    $text =~ s/([\s\n]+)hivecontext([\s\n\.]+)/$1HiveContext$2/gi;
    $text =~ s/human readable/human-readable/gi;
    $text =~ s/functional style/functional-style/gi;
    $text =~ s/([\s\n]+)tungsten/$1Tungsten/gi;
    $text =~ s/([\s\n]+)jars([\s\n]+)/$1JARs$2/gi;
    $text =~ s/([\s\n]+)jar([\s\n]+)/$1JAR$2/gi;
    $text =~ s/([\s\n]+)3rd([\s\n]+)/$1third$2/gi;
    $text =~ s/([\s\n]+)row([\s\n]+)objects/$1`Row`$2objects/gi;
    $text =~ s/accessiable/accessible/gi;
    $text =~ s/catalyst/Catalyst/gi;
    $text =~ s/echo system/ecosystem/gi;
    $text =~ s/like::http/link::http/g;
    $text =~ s/like::\$\$/link::\$\$/g;
    $text =~ s/(\s+i)n (m)emory(\s+)/$1n-$2emory$3/gi;
    $text =~ s/fit in-memory/fit in memory/gi;
    $text =~ s/\s*footnote:\[([\w\s\.]+)\]\./.footnote:[$1]/gi;
    $text =~ s/(\s+[pP])arameters([\s\w\.])/$1arameters$2/gi;
    $text =~ s/examples\/GoldiLocks\//examples\/goldilocks\//gi;
    $text =~ s/examples\/goldilocks\/GoldiLocks/examples\/goldilocks\/Goldilocks/gi;
    $text =~ s/Graph X/GraphX/g;
    $text =~ s/DrydLINQ/DryadLINQ/gi;
    $text =~ s/DrayadLINQ/DryadLINQ/gi;
    $text =~ s/(\s+)data frame/$1DataFrame/gi;
    $text =~ s/DraydLINQ/DryadLINQ/gi;
    $text =~ s/\.scla/\.scala/g;
    $text =~ s/(\s+)ap+ache/$1Apache/gi;
    $text =~ s/(\s+)console sink/$1Console sink/gi;
    $text =~ s/(p)reperation/$1reparation/gi;
    $text =~ s/convienent/convenient/gi;
    $text =~ s/convient/convenient/gi;
    $text =~ s/MLLib/MLlib/g;
    $text =~ s/(\s+)graph frames/$1GraphFrames/gi;
    $text =~ s/(\s+)sinlge/$1single/gi;
    $text =~ s/UDFS/UDFs/gi;
    $text =~ s/UDAFS/UDAFs/gi;
    $text =~ s/Kyro/Kryo/gi;
    $text =~ s/tableau/Tableau/gi;
    $text =~ s/(\s+)SparkSQL/$1Spark SQL/g;
    $text =~ s/(\s+)there model/$1their model/g;
    $text =~ s/(\s)maven(\s)/$1Maven$2/g;
    $text =~ s/(\s+)re-used(\s)/$1reused$2/g;
    $text =~ s/time consuming/time-consuming/g;
    $text =~ s/sub directories/subdirectories/g;
    $text =~ s/(p)oission/$1oisson/gi;
    $text =~ s/(b)enoulli/$1ernoulli/gi;
    $text =~ s/(p)roperty (b)ased/$1roperty-$2ased/gi;
    $text =~ s/docker/Docker/gi;
    $text =~ s/(m)eta algorithms/$1eta-algorithms/gi;
    $text =~ s/(c)ounter intuitive/$1ounter-intuitive/gi;
    $text =~ s/(i)nstalation/$1nstallation/gi;
    # Normally we'd auto cap Kubernetes buuuut in-line results are throwing that off
    $text =~ s/(\s|\s\.)(k)ubernetes/$1$2ubernetes/gi;
    $text =~ s/(\s|\s\.)(k)uberntes/$1$2ubernetes/gi;
    # Include's slightly off
    $text =~ s/include::intro-to-ml-with-kubeflow-examples/include::examples/g;
    $text =~ s/include::introduction-to-ml-with-kubeflow-examples/include::examples/g;
    # Slightly off links:
    $text =~ s/link:(\$\$|)link:\$\$/link:\$\$/g;
    $text =~ s/link:\$\$\$\$/link:\$\$/g;
    $text =~ s/link:\$h/link:\$\$h/g;
    $text =~ s/link:\$\$(h[^\$\s]*)\$\[/link:\$\$$1\$\$\[/g;
    # Pluralize some things
    $text =~ s/data scientist and data engineers/data scientists and data engineers/g;
    $text =~ s/data scientists and data engineer/data scientists and data engineers/g;

    open (my $out, ">$file");
    print $out $text;
    close($out);
}

open (my $files, "ls -1 *.asciidoc |");
while (my $file = <$files>) {
    chomp($file);
    print "Updating $file \n";
    process_file($file);
}
print "Done!\n";
