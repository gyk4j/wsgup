#!/usr/bin/perl

# Prerequisites
# Install cpanm: cpan App::cpanminus
# Install modules: cpanm --cpanfile cpanfile --installdeps .

use strict;
use warnings;

use Data::Dumper;
use File::Slurp;
use JSON;
use Crypt::AuthEnc::CCM; # OO-style
# use Crypt::AuthEnc::CCM qw(ccm_decrypt_verify); # functional style

use constant {
    TAG_LENGTH => 16,
    NONCE_LENGTH => 12,
    ALGORITHM => 'AES',
    ADD_ASSOCIATED_DATA => "",
};

die "Wrong tag length" unless (TAG_LENGTH == (128 / 8));

my $register = read_file('../../shared/register.json');
my $registration = JSON->new->utf8->decode($register);

# print Dumper($registration);

# printf("date   : %02d-%02d-%04d\n", 
    # $registration->{"date"}{"day"}, 
    # $registration->{"date"}{"month"},
    # $registration->{"date"}{"year"});

# printf("otp    : %06d\n", $registration->{"otp"});
# printf("transid: %s\n", $registration->{"transid"});

# Read test data from file
my $test_data = read_file('../../shared/testdata.json');

# Parse JSON test data
my $res = JSON->new->utf8->decode($test_data);

# print Dumper($res);

# printf("iv           = %s\n", $res->{"body"}{"iv"});
# printf("enc_userid   = %s\n", $res->{"body"}{"enc_userid"});
# printf("tag_userid   = %s\n", $res->{"body"}{"tag_userid"});
# printf("userid       = %s\n", $res->{"body"}{"userid"});
# printf("enc_password = %s\n", $res->{"body"}{"enc_password"});
# printf("tag_password = %s\n", $res->{"body"}{"tag_password"});

# Build the decryption key
# ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(); # today
# strftime "%e%m", localtime;

my $date_str = sprintf("%d%02d", 
    $registration->{"date"}{"day"}, 
    $registration->{"date"}{"month"});
my $date_hex = sprintf("%03x", $date_str);

my $otp_hex = sprintf("%05x", $registration->{"otp"});

my $transid = $registration->{"transid"};

my $key_hex = "${date_hex}${transid}${otp_hex}";

my $key = pack('H*', $key_hex);
die "Wrong key length" unless length($key) == 16;

# Prepare to decrypt user ID and password
my $nonce = $res->{"body"}{"iv"};
die "Wrong IV length" unless length($nonce) == NONCE_LENGTH;

# functional style
# $plaintext = ccm_decrypt_verify('AES', $key, $nonce, $adata, $ciphertext, $tag);
# print $plaintext;

# Decrypt userid
my $enc_userid = $res->{"body"}{"enc_userid"};
my $enc_userid_bin = pack('H*', $enc_userid);

my $tag_userid = $res->{"body"}{"tag_userid"};
my $tag_userid_bin = pack('H*', $tag_userid);
die "Wrong tag length" unless length($tag_userid_bin) == TAG_LENGTH;

my $cipher = Crypt::AuthEnc::CCM->new(
    ALGORITHM, 
    $key, 
    $nonce, 
    ADD_ASSOCIATED_DATA, 
    TAG_LENGTH, 
    length($enc_userid_bin));
    
my $userid = $cipher->decrypt_add($enc_userid_bin);
my $tag = $cipher->decrypt_done($tag_userid_bin);

printf("User ID  = %s\n", $userid);

# Decrypt password
my $enc_password = $res->{"body"}{"enc_password"};
my $enc_password_bin = pack('H*', $enc_password);

my $tag_password = $res->{"body"}{"tag_password"};
my $tag_password_bin = pack('H*', $tag_password);
die "Wrong tag length" unless length($tag_password_bin) == TAG_LENGTH;

$cipher = Crypt::AuthEnc::CCM->new(
    ALGORITHM, 
    $key, 
    $nonce, 
    ADD_ASSOCIATED_DATA, 
    TAG_LENGTH, 
    length($enc_password_bin));
    
my $password = $cipher->decrypt_add($enc_password_bin);
$tag = $cipher->decrypt_done($tag_password_bin);

printf("Password = %s\n", $password);
