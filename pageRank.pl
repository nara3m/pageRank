use strict;
use warnings;

my @nodes=(0..12);
my $size=@nodes;

my %count=(0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,0,10,0,11,0,12,0);

my($i,$j,$k,$s,@matrix);
my $matrix = &bot;
@matrix = @$matrix;

print "\nOriginal Network of Wikipedia page links :\n";
&print_graph(@matrix);
&page_ranking(@matrix);

@matrix=&links_swapping(@matrix);
print "\nGraph with links swapped :\n";
&print_graph(@matrix);
&page_ranking(@matrix);

@matrix = &fixed_links(@matrix);
print "\nErdos-Renyi random graph :\n";
&print_graph(@matrix);
&page_ranking(@matrix);

#************

sub page_ranking {
	
	@matrix=@_;
	#print join(",", %count);print"\n";
	print "\nNo. of iterations to be done for calculating page rank of above graph : ";
	my $m=<stdin>;chomp($m);

	$i=int(rand(13));
	my $p=0.15;my (@out_links,$size);

	$k=0;
	while($k<$m){
		if(rand()<(1-$p)){ 
			for($s=0;$s<13;$s++){
				if($matrix[$i][$s]==1){
					$s=14; 
				}
			}
	
			if ($s == 15){ 
				do{
					$j=int(rand(13));
				}
				until ($matrix[$i][$j]==1);	
			
				$i=$j;
				$count{$i}++;
				$k++;
			}
	
			else {
				if (rand()<$p){
				$i=int(rand(13));
				$count{$i}++;
				$k++;
				}
			}
		}
	
		else {
			if (rand()<$p){
			$i=int(rand(13));
			$count{$i}++;
			$k++;
			}	
		}

	}	

	my @sorted_ranks = sort by_rank keys %count;
	print"\nRank\tNode\tVisits\n";
	$i=1;foreach(@sorted_ranks){
	print "$i\t$_\t$count{$_}\n";$i++;}

	my $sum=0;
	foreach(values %count){
	$sum=$sum+$_;
	}
	$sum=$sum/12;

	my $std=0;
	foreach(values %count){
	$std=$std+(($_-$sum)**2);
	}

	$std=sqrt($std/12);

	print"\nMaximum : $count{$sorted_ranks[0]}\n";
	print"Minimum : $count{$sorted_ranks[12]}\n";
	print"Mean : ";
	print sprintf "%.2f", "$sum"; print "\n";
	print"Standard Deviation : ";
	print sprintf "%.2f", "$std"; print "\n";

}

sub by_rank { 
	$count{$b} <=> $count{$a} 
}

sub print_graph
{
	my ($x,$y);
	print "\n";
	@matrix=@_;
	for ($x=0;$x<$size; $x++){
		for ($y=0;$y<$size; $y++){
			print "$matrix[$x][$y]";
		}
		print "\n";
	}
}

sub nos_links
{
	# finding number of links

	my @matrix=@_;
	my $nos_links=0;
	my ($x,$y);

	for ($x=0;$x<$size; $x++){
		for ($y=0;$y<$size; $y++){
			if ($matrix[$x][$y]==1) { $nos_links++;}
		}
	}
	return $nos_links;
}

sub fixed_links
{
	@matrix = @_;
	my $nos_links = &nos_links(@matrix);
	my ($y,$r1, $r2);
	
	for ($r1=0;$r1<$size;$r1++){
		for ($r2=0;$r2<$size;$r2++){
			$matrix[$r1][$r2]=0;
		}
	}
	
	$y=0;
	while($y<=$nos_links){
		$r1=int(rand($size));
		$r2=int(rand($size));
		if ($matrix[$r1][$r2]==1){}
		else {$matrix[$r1][$r2]=1;$y++;}
	}
	return @matrix;
}


sub links_swapping
{
	@matrix=@_;
	my $nos_links = &nos_links(@matrix);
	my ($x,$r1,$r2,$r3, $r4);

	$x=0;
	while ($x<=($nos_links*3)){
		$r1=int(rand($size));
		$r2=int(rand($size));
		$r3=int(rand($size));
		$r4=int(rand($size));
		
		# trying to swap $matrix[$r1][$r2] and $matrix[$r3][$r4] 
		
		if ($r1==$r2){} #don't swap
		elsif ($r3==$r4){} #don't swap
		elsif ($matrix[$r1][$r4]==1){} # dont swap
		elsif ($matrix[$r3][$r2]==1){} # dont swap
		elsif (($matrix[$r1][$r2]==0)or($matrix[$r3][$r4]==0)){} # dont swap
		else {
			$matrix[$r1][$r2]=0;
			$matrix[$r1][$r4]=1;
			$matrix[$r3][$r4]=0;
			$matrix[$r3][$r2]=1;
			$x++;
		}
	}
	return @matrix;	
}

sub bot 
{

my ($x,$y, $link, @list);

print "Give file name that contians list of URL's : ";
my $f1 = <stdin>;chomp($f1);
open LINK_LIST, "$f1";

$x=0; my $found;
while (<LINK_LIST>) {
	$_ =~ s/\(/\\(/g;
	$_ =~ s/\)/\\)/g;
	`wget -O $x $_`;
	open LINK_LIST_AGAIN, "$f1";
	$y=0;
	while ($link = <LINK_LIST_AGAIN>) {
		$found =0;
		if ($y != $x ){ # removing self links
			chomp($link);
			$link =~ s/http\:\/\/en\.wikipedia\.org//;
			open PAGE, "$x";
			while (<PAGE>) {
				if ($_ =~ m{\Q$link"\E}i){
					$list[$x][$y] = 1;
					$found =1;
					last;
				}
			}
			close PAGE;
		}
		if ($found == 0) {$list[$x][$y] = 0;}
		$y++;
	}
	close LINK_LIST_AGAIN;
	`rm $x`;
	$x++;
}	

close LINK_LIST;

return \@list;

}


__END__;
