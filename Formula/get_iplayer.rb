class GetIplayer < Formula
  desc "Utility for downloading TV and radio programmes from BBC iPlayer"
  homepage "https://github.com/get-iplayer/get_iplayer"
  url "https://github.com/get-iplayer/get_iplayer/archive/v3.06.tar.gz"
  sha256 "fba3f1abd01ca6f9aaed30f9650e1e520fd3b2147fe6aa48fe7c747725b205f7"
  head "https://github.com/get-iplayer/get_iplayer.git", :branch => "develop"

  bottle do
    cellar :any_skip_relocation
    sha256 "1ed429e5a0b2df706f9015c8ca40f5b485e7e0ae68dfee45c76f784eca32b553" => :high_sierra
    sha256 "1c9101656db2554d72b6f53d13fba9f84890f82119414675c5f62fb7e126373e" => :sierra
    sha256 "1c9101656db2554d72b6f53d13fba9f84890f82119414675c5f62fb7e126373e" => :el_capitan
  end

  depends_on "atomicparsley" => :recommended
  depends_on "ffmpeg" => :recommended

  depends_on :macos => :yosemite

  resource "IO::Socket::IP" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/IO-Socket-IP-0.39.tar.gz"
    sha256 "11950da7636cb786efd3bfb5891da4c820975276bce43175214391e5c32b7b96"
  end

  resource "Mojolicious" do
    url "https://cpan.metacpan.org/authors/id/S/SR/SRI/Mojolicious-7.48.tar.gz"
    sha256 "86d28e66a352e808ab1eae64ef93b90a9a92b3c1b07925bd2d3387a9e852388e"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"

    resources.each do |r|
      r.stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end
    end

    inreplace ["get_iplayer", "get_iplayer.cgi"] do |s|
      s.gsub!(/^(my \$version_text);/i, "\\1 = \"#{pkg_version}-homebrew\";")
      s.gsub! "#!/usr/bin/env perl", "#!/usr/bin/perl"
    end

    bin.install "get_iplayer", "get_iplayer.cgi"
    bin.env_script_all_files(libexec/"bin", :PERL5LIB => ENV["PERL5LIB"])
    man1.install "get_iplayer.1"
  end

  test do
    output = shell_output("\"#{bin}/get_iplayer\" --refresh --refresh-include=\"BBC None\" --quiet dontshowanymatches 2>&1")
    assert_match "get_iplayer #{pkg_version}-homebrew", output, "Unexpected version"
    assert_match "INFO: 0 matching programmes", output, "Unexpected output"
    assert_match "INFO: Indexing tv programmes (concurrent)", output,
                         "Mojolicious not found"
  end
end
